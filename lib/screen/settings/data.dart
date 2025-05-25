import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:klaws/model/article.dart';
import 'package:raven/model/user_subscription.dart';
import 'package:raven/provider/repo.dart';
import 'package:raven/repository/preferences/bookmarks.dart';
import 'package:raven/repository/preferences/content.dart';
import 'package:raven/repository/preferences/internal.dart';
import 'package:raven/repository/preferences/saved.dart';
import 'package:raven/repository/preferences/subscriptions.dart';
import 'package:raven/screen/logs.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {

  final String subscriptionsSelectedJson = "subscriptions_selected.json";
  final String subscriptionsCustomJson = "subscriptions_custom.json";
  final String subscriptionsZip = "raven_subscriptions.zip";
  final String savedArticlesJson = "saved_articles.json";
  final String bookmarkedArticlesJson = "bookmarked_articles.json";
  final String reposJson = "repos.json";
  final String articlesZip = "raven_articles.zip";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Data'),
      ),
      body: ListView(
        children: [
          ListTile(
            subtitle: const Text('Backup\n(Subscriptions and Saved articles)'),
            visualDensity: VisualDensity.compact,
            dense: true,
          ),
          ListTile(
            leading: const Icon(Icons.favorite_rounded),
            title: const Text('Export'),
            onTap: () async {
              // TODO: Test below android 13
              try {
                await backupSubscriptions().then((path) {
                  showSnackBar(context, 'Export successful! $path');
                });
              } catch (e) {
                showSnackBar(context, 'Export failed, ${e.toString()}');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_outline_rounded),
            title: const Text('Import'),
            onTap: () async {
              try {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  allowMultiple: false,
                );

                if (result != null) {
                  File file = File(result.files.single.path!);
                  await importSubscriptions(file);
                  showSnackBar(context, 'Import successful!');
                }
              } catch (e) {
                print(e);
                showSnackBar(context, 'Import failed. Backup file may be incorrect.');
              }
            },
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.receipt_long_rounded),
            title: const Text('Network logs'),
            onTap: () async {
              var directory = await getTemporaryDirectory();
              File logsFile = File(
                '${directory.path}/raven_logs.txt',
              );
              String logs = await logsFile.readAsString();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LogsScreen(logs: logs),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_delete_rounded),
            title: const Text('Clear Cache'),
            onTap: () {
              HiveCacheStore(Internal.appDirectory).clean();
            },
          ),
        ],
      ),
    );
  }

  Future<String> backupSubscriptions() async {
    await requestStoragePermission();
    String parentPath = await backupPath();
    var zip = ZipFileEncoder();
    zip.create('$parentPath/$subscriptionsZip');
    var file = File(
      '$parentPath/$subscriptionsSelectedJson',
    );
    await file.create(recursive: true);
    var encoded = jsonEncode(
      UserSubscriptionPref.selectedSubscriptions
          .map((e) => e.toJson())
          .toList(),
    );
    await file.writeAsString(encoded);
    await zip.addFile(file);
    await file.delete();

    file = File(
      '$parentPath/$subscriptionsCustomJson',
    );
    await file.create(recursive: true);
    encoded = jsonEncode(
      UserSubscriptionPref.customSubscriptions
          .map((e) => e.toJson())
          .toList(),
    );
    await file.writeAsString(encoded);
    await zip.addFile(file);

    file = File('$parentPath/$savedArticlesJson',);
    await file.create(recursive: true);
    encoded = jsonEncode(
      SavedArticles.saved.values
          .map((e) => e.toJson())
          .toList(),
    );
    await file.writeAsString(encoded);
    await zip.addFile(file);

    file = File('$parentPath/$bookmarkedArticlesJson',);
    await file.create(recursive: true);
    encoded = jsonEncode(
      BookmarkedArticles.bookmarks.values
          .map((e) => e.toJson())
          .toList(),
    );
    await file.writeAsString(encoded);
    await zip.addFile(file);


    file = File('$parentPath/$reposJson',);
    await file.create(recursive: true);
    encoded = jsonEncode(
      ContentPref.repos.map((e) => e.url).toList(),
    );
    await file.writeAsString(encoded);
    await zip.addFile(file);

    await file.delete();
    zip.closeSync();
    return 'Saved to\n${Directory(parentPath)}/$subscriptionsZip';
  }

  Future<String> backupPath() async {
    var directoryPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    var directory = Directory(directoryPath);
    var parentPath = "${directory.path}/raven/backup";
    return parentPath;
  }

  Future<bool> importSubscriptions(File file) async {
    await requestStoragePermission();
    var directory = "${(await getTemporaryDirectory()).path}backup/extracted/";
     try {

       final bytes = file.readAsBytesSync();
       final archive = ZipDecoder().decodeBytes(bytes);
       for (final file in archive) {
         final filename = file.name;
         if (file.isFile) {
           final data = file.content as List<int>;
           File('$directory/$filename')
             ..createSync(recursive: true)
             ..writeAsBytesSync(data);
         }
       }

       file = File('$directory/$reposJson');
       var content = await file.readAsString();
       var repos = jsonDecode(content);
       for (var repo in repos) {
         try {
           RepoHelper().tryImportingRepo(repo);
         } catch (e) { continue; }
       }

       file = File('$directory/$subscriptionsSelectedJson');
       content = await file.readAsString();
       List decoded = jsonDecode(content);
       List<UserFeedSubscription> subscriptions =
       decoded.map((e) => UserFeedSubscription.fromJson(e)).toList();
       for (var subscription in subscriptions) {
         if (UserSubscriptionPref.selectedSubscriptions
             .contains(subscription)) {
           continue;
         }
         UserSubscriptionPref.selectedSubscriptions =
         UserSubscriptionPref.selectedSubscriptions..add(subscription);
       }


       file = File('$directory/$subscriptionsCustomJson');
       content = await file.readAsString();
       decoded = jsonDecode(content);
       subscriptions = decoded.map((e) => UserFeedSubscription.fromJson(e)).toList();
       for (var subscription in subscriptions) {
         if (UserSubscriptionPref.customSubscriptions
             .contains(subscription)) {
           continue;
         }
         UserSubscriptionPref.customSubscriptions =
         UserSubscriptionPref.customSubscriptions..add(subscription);
       }

       File jsonFile = File('$directory/$savedArticlesJson');
       content = await jsonFile.readAsString();
       decoded = jsonDecode(content);
       List<Article> articles =
       decoded.map((e) => Article.fromJson(e)).toList();
       for (var article in articles) {
         if (SavedArticles.saved.values.map((e) => e.url).toList().contains(article.url)) {
           continue;
         }
         SavedArticles.saveArticle(article);
       }

       jsonFile = File('$directory/$bookmarkedArticlesJson',);
       content = await jsonFile.readAsString();
       decoded = jsonDecode(content);
       articles =
       decoded.map((e) => Article.fromJson(e)).toList();
       for (var article in articles) {
         if (BookmarkedArticles.bookmarks.values.map((e) => e.url).toList().contains(article.url)) {
           continue;
         }
         BookmarkedArticles.saveArticle(article);
       }


       return true;
     } catch (e) {
       return false;
     } finally {
       await File(directory).delete(recursive: true);
     }
  }

  void showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
    ));
  }

  Future<void>  requestStoragePermission() async {
    if (Internal.sdkVersion >= 33) {
      await Permission.manageExternalStorage.request();
    } else {
      await Permission.storage.request();
    }
  }

  Future<List<T>> _readAndDecodeJsonList<T>(String directory, String filename, T Function(Map<String, dynamic>) fromJson) async {
    final file = File('$directory/$filename');
    if (!await file.exists()) {
      return [];
    }
    final content = await file.readAsString();
    List decoded = jsonDecode(content);
    return decoded.map((e) => fromJson(e)).toList();
  }

}
