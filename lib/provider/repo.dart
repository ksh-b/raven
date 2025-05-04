import 'package:klaws/model/source/repo.dart';
import 'package:raven/model/stored_repo.dart';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:klaws/model/source/nest.dart';
import 'package:klaws/model/watch.dart';
import 'package:klaws/provider/repo_provider.dart';
import 'package:klaws/repository/json.dart';
import 'package:path_provider/path_provider.dart';
import 'package:klaws/model/publisher.dart';
import 'package:klaws/model/source/other_version.dart';
import 'package:klaws/model/source/sources_json.dart';
import 'package:klaws/model/source/watch_dart.dart';
import 'package:raven/provider/permissions.dart';
import 'package:raven/repository/preferences/content.dart';
import 'package:raven/service/http_client.dart';

class RepoHelper {
  Future<String> updateRepo(StoredRepo repo) async {
    Repo? repo2 = await RepoProvider.getRepo(repo.url);
    if (repo2==null) {
      return "Failed to resolve ${repo.name}";
    }
    // if(repo2.lastUpdate>repo.lastUpdated) {
      await deleteRepo(repo);
      await tryImportingRepo(repo.url);
    // }
    return "Updated ${repo.name}";
  }

  Future<void> extractFromRepo(Repo repo) async {
    await PermissionsProvider().requestStoragePermission();
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
    for (var source_ in sources.feeds) {
      final file = File("$extractedDir${source_.file}");
      String jsonString = await file.readAsString();
      Nest source =
      Nest.fromJson(json.decode(jsonString));
      Source jsonSource = JsonSource(
        id: '${repo.id}/${source.name}',
        hasCustomSupport: source.supportsCustomCategory,
        nest: source,
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
        Nest source =
        Nest.fromJson(json.decode(jsonString));
        jsonSource.otherVersions.add(JsonSource(
          id: '${repo.id}/${ov.name}',
          hasCustomSupport: source.supportsCustomCategory,
          nest: source,
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
    ContentPref.repos = ContentPref.repos..removeWhere((element) => element.id==repo.id,);
    ContentPref.feedSources = ContentPref.feedSources..removeWhere((source) {
      int lastIndex = source.id.lastIndexOf('/');
      String repoId1 = source.id.substring(0, lastIndex);
      String repoId2 = repo.id;
      return repoId1==repoId2;
    });
    await Directory(repo.directory).delete(recursive: true);
  }

  Future<String> tryImportingRepo(String urlFromUser) async {
    if(urlFromUser.isEmpty) {
      return "";
    }
    if (Uri.tryParse(urlFromUser) == null) {
      return "Invalid URL";
    }
    Repo? repo = await RepoProvider.getRepo(urlFromUser);

    if(repo==null) {
      return "Failed to load details. Please try again later";
    }

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

    await PermissionsProvider().requestStoragePermission();
    var directoryParent = await getExternalStorageDirectory();
    var directory = "${directoryParent!.path}/providers/subscription";
    ContentPref.repos = ContentPref.repos.toList()
      ..add(
        StoredRepo(
            id: repo.id,
            url: repo.url,
            name: repo.name,
            description: repo.description,
            lastChecked: DateTime.timestamp().millisecondsSinceEpoch,
            lastUpdated: repo.lastUpdate,
            directory: '$directory/${repo.zipFolder}/'
        ),
      );
    return "Success";
  }

  Future<String> getExtractedDir(Repo repo) async {
    await PermissionsProvider().requestStoragePermission();
    var directoryParent = await getExternalStorageDirectory();
    var directory = "${directoryParent!.path}/providers/subscription";
    var extractedDir = '$directory/${repo.zipFolder}/';
    return extractedDir;
  }


}
