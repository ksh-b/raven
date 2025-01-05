import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/model/source/other_version.dart';
import 'package:raven/model/source/repo.dart';
import 'package:raven/model/source/source_dart.dart';
import 'package:raven/model/source/sources_json.dart';
import 'package:raven/model/source/watch_dart.dart';
import 'package:raven/model/stored_repo.dart';
import 'package:raven/repository/git/github.dart';
import 'package:raven/repository/news/custom/json.dart';
import 'package:raven/repository/preferences/content.dart';
import 'package:raven/repository/preferences/internal.dart';
import 'package:raven/service/http_client.dart';

import '../model/watch.dart';

class SubscriptionsManager extends StatefulWidget {
  const SubscriptionsManager({super.key});

  @override
  State<SubscriptionsManager> createState() => _SubscriptionsManagerState();
}

class _SubscriptionsManagerState extends State<SubscriptionsManager> {
  Future<void> requestStoragePermission() async {
    if (Internal.sdkVersion >= 33) {
      await Permission.manageExternalStorage.request();
    } else {
      await Permission.storage.request();
    }
  }

  Future<String> getUrlFromUser() async {
    String text = "";
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Repo'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Github Repo URL',
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                text = controller.text;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return text;
  }

  Future<String> tryImportingRepo() async {
    var urlFromUser = await getUrlFromUser();
    if (urlFromUser.isEmpty || Uri.tryParse(urlFromUser) == null) {
      return "Invalid URL";
    }
    Repo repo = resolveRepo(urlFromUser);
    if (ContentPref.repos
        .map((e) => e.id,)
        .toList()
        .contains(repo.id)) {
      return "Already exists";
    }

    try {
      await extractFromRepo(repo);
    } catch (e) {
      print(e);
      return "Fail";
    }

    ContentPref.repos = ContentPref.repos.toList()
      ..add(
        StoredRepo(
          id: repo.id,
          url: repo.url,
          name: repo.name,
          description: repo.description,
          lastChecked: DateTime.timestamp().millisecondsSinceEpoch,
          lastUpdated: await repo.lastCommit(),
        ),
      );
    return "Success";
  }

  Repo resolveRepo(String urlFromUser) {
    Repo repo = Github(url: urlFromUser);
    return repo;
  }



  Future<String> getExtractedDir(Repo repo) async {
    await requestStoragePermission();
    var directoryParent = await getExternalStorageDirectory();
    var directory = "${directoryParent!.path}/providers/subscription";
    var extractedDir = '$directory/${repo.zipFolder}-${repo.defaultBranch}/';
    return extractedDir;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage feed providers"),
      ),
      body: ValueListenableBuilder(
        valueListenable: Internal.settings.listenable(keys: [ContentPrefType.repos.name]),
        builder: (context, value, child) {
          return ListView(
            children: ContentPref.repos.map(
                  (repo) {
                return ListTile(
                  title: Text(repo.name),
                  subtitle: Text(repo.description),
                  trailing: Flex(
                    mainAxisSize: MainAxisSize.min,
                    direction: Axis.horizontal,
                    children: [
                      IconButton(
                        onPressed: () async {
                          await deleteRepo(repo);
                        },
                        icon: Icon(Icons.delete),
                      ),
                      IconButton(
                        onPressed: () async {
                          await deleteRepo(repo);
                          await extractFromRepo(resolveRepo(repo.url));
                        },
                        icon: Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                );
              },
            ).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          var result = await tryImportingRepo();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result),
            ),
          );
        },
      ),
    );
  }

  Future<void> extractFromRepo(Repo repo) async {
    await requestStoragePermission();
    var directoryParent = await getExternalStorageDirectory();
    var directory = "${directoryParent!.path}/providers/subscription/";
    if (await Directory("${directoryParent.path}/providers/").exists()) {
      await Directory("${directoryParent.path}/providers/")
          .delete(recursive: true);
    }
    await Directory(directory).create(recursive: true);

    var zipDir = '${directory}main.zip';
    String extractedDir = await getExtractedDir(repo);
    if(Directory(extractedDir).existsSync()) {
      Directory(extractedDir).deleteSync(recursive: true);
    }
    if(File(zipDir).existsSync()) {
      File(zipDir).deleteSync(recursive: true);
    }
    await dio().download(
      repo.latestZip,
      zipDir,
    );

    await extractFileToDisk(
      zipDir,
      directory,
    );
    final sourcesFile = File("${extractedDir}sources.json");
    String sourcesJson = await sourcesFile.readAsString();
    var sources = ExternalSources.fromJson(json.decode(sourcesJson));
    repo.name = sources.name;
    repo.description = sources.description;
    for (var source_ in sources.feeds) {
      final file = File("$extractedDir${source_.file}");
      String jsonString = await file.readAsString();
      ExternalSource source =
      ExternalSource.fromJson(json.decode(jsonString));
      Source jsonSource = JsonSource(
        id: '${repo.repo}/${source.name}',
        hasCustomSupport: source.supportsCustomCategory,
        externalSource: source,
        hasSearchSupport: source.searchUrl.isNotEmpty,
        homePage: source.homePage,
        iconUrl: source.iconUrl,
        name: source.name,
        siteCategories: source.category,
      );

      ContentPref.feedSources = ContentPref.feedSources.toList()
        ..removeWhere((element) {
          return jsonSource.id == element.id;
        });
      for (OtherVersion ov in source_.otherversions) {
        final file = File(
          "$extractedDir/${ov.file}",
        );
        String jsonString = await file.readAsString();
        ExternalSource source =
        ExternalSource.fromJson(json.decode(jsonString));
        jsonSource.otherVersions.add(JsonSource(
          id: '${repo.repo}/${ov.name}',
          hasCustomSupport: source.supportsCustomCategory,
          externalSource: source,
          hasSearchSupport: source.searchUrl.isNotEmpty,
          homePage: source.homePage,
          iconUrl: source.iconUrl,
          name: source.name,
          siteCategories: source.category,
        ));
      }
      if (ContentPref.feedSources.map((e) => e.id).contains(jsonSource.id)) {
        ContentPref.feedSources = ContentPref.feedSources
          ..removeWhere((e) => e.id == jsonSource.id);
      }
      ContentPref.feedSources = ContentPref.feedSources.toList()..add(jsonSource);
    }


    for (var watch in sources.watches) {
      final file = File("$extractedDir${watch.file}");
      String jsonString = await file.readAsString();
      WatchImport source = WatchImport.fromJson(json.decode(jsonString));
      Watch watchIt = Watch(
        id: '${repo.repo}/${source.name}',
        watch: source,
      );
      if (ContentPref.watchSources.map((e) => e.id).contains(watchIt.id)) {
        ContentPref.watchSources = ContentPref.watchSources
          ..removeWhere((e) => e.id == watchIt.id);
      }
      ContentPref.watchSources = ContentPref.watchSources.toList()..add(watchIt);
    }
  }

  Future<void> deleteRepo(StoredRepo repo) async {
    var dRepo = await getExtractedDir(resolveRepo(repo.url));
    ContentPref.repos = ContentPref.repos..removeWhere((element) => element.id==repo.id,);
    ContentPref.feedSources = ContentPref.feedSources..removeWhere((source) {
      int lastIndex = source.id.lastIndexOf('/');
      String repoId1 = source.id.substring(0, lastIndex);
      int index = repo.id.indexOf('/');
      String repoId2 = repo.id.substring(index + 1);
      return repoId1==repoId2;
    });
    await Directory(dRepo).delete(recursive: true);
  }
}
