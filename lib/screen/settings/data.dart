import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/user_subscription.dart';
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

  final String subscriptionsSelectedJson = "backup/subscriptions_selected.json";
  final String subscriptionsCustomJson = "backup/subscriptions_custom.json";
  final String subscriptionsZip = "backup/raven_subscriptions.zip";
  final String articlesJson = "backup/articles.json";
  final String articlesZip = "backup/raven_articles.zip";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Data'),
      ),
      body: ListView(
        children: [
          ListTile(
            subtitle: const Text('Export'),
            visualDensity: VisualDensity.compact,
            dense: true,
          ),
          ListTile(
            leading: const Icon(Icons.favorite_rounded),
            title: const Text('Subscriptions'),
            onTap: () async {
              try {
                await backupSubscriptions();
                showSnackBar(context, 'Export successful!');
              } catch (e) {
                showSnackBar(context, 'Export failed, ${e.toString()}');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.save_rounded),
            title: const Text('Saved articles'),
            onTap: () async {
              try {
                await backupSavedArticles();
                showSnackBar(context, 'Export successful!');
              } catch (e) {
                showSnackBar(context, 'Export failed, ${e.toString()}');
              }
            },
          ),
          Divider(),
          ListTile(
            subtitle: const Text('Import'),
            visualDensity: VisualDensity.compact,
            dense: true,
          ),
          ListTile(
            leading: const Icon(Icons.favorite_outline_rounded),
            title: const Text('Subscriptions'),
            onTap: () async {
              try {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  allowMultiple: false,
                  allowedExtensions: ["zip"],
                  type: FileType.custom
                );

                if (result != null) {
                  File file = File(result.files.single.path!);
                  await importSubscriptions(file);
                  showSnackBar(context, 'Import successful!');
                }
              } catch (e) {
                showSnackBar(context, 'Import failed. Backup file may be incorrect.');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.save_outlined),
            title: const Text('Saved articles'),
            onTap: () async {
              try {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                    allowMultiple: false,
                    allowedExtensions: ["zip"],
                    type: FileType.custom,
                );

                if (result != null) {
                  File file = File(result.files.single.path!);
                  await importSavedArticles(file);
                  showSnackBar(context, 'Import successful!');
                }
              } catch (e) {
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

  Future<void> backupSavedArticles() async {
    await requestStoragePermission();
    var directory = await FilePicker.platform.getDirectoryPath();
    var zip = ZipFileEncoder();
    zip.create('${directory!}/$articlesZip');
    var file = File(
      '$directory/$articlesJson',
    );
    await file.create(recursive: true);
    var encoded = jsonEncode(
      SavedArticles.saved.values
          .map((e) => e.toJson())
          .toList(),
    );
    await file.writeAsString(encoded);
    await zip.addFile(file);
    await file.delete();
    zip.closeSync();
  }

  Future<void> backupSubscriptions() async {
    await requestStoragePermission();
    var directory = await FilePicker.platform.getDirectoryPath();
    var zip = ZipFileEncoder();
    zip.create('${directory!}/$subscriptionsZip');
    var file = File(
      '$directory/$subscriptionsSelectedJson',
    );
    await file.create(recursive: true);
    var encoded = jsonEncode(
      SubscriptionPref.selectedSubscriptions
          .map((e) => e.toJson())
          .toList(),
    );
    await file.writeAsString(encoded);
    await zip.addFile(file);
    await file.delete();

    file = File(
      '$directory/$subscriptionsCustomJson',
    );
    await file.create(recursive: true);
    encoded = jsonEncode(
      SubscriptionPref.customSubscriptions
          .map((e) => e.toJson())
          .toList(),
    );
    await file.writeAsString(encoded);
    await zip.addFile(file);
    await file.delete();
    zip.closeSync();
  }

  Future<void> importSavedArticles(File zipFile) async {
    await requestStoragePermission();
    var directory = await getTemporaryDirectory();
    final bytes = zipFile.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File('${directory.path}/backup/extracted/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      }
    }
    File jsonFile = File(
      '${directory.path}/backup/extracted/articles.json',
    );

    var content = await jsonFile.readAsString();
    List decoded = jsonDecode(content);
    List<Article> articles =
    decoded.map((e) => Article.fromJson(e)).toList();
    for (var article in articles) {
      if (SavedArticles.saved.values.map((e) => e.url).toList().contains(article.url)) {
        continue;
      }
      SavedArticles.saved.add(article);
    }
  }

  Future<bool> importSubscriptions(File file) async {
    await requestStoragePermission();
    var directory = await getTemporaryDirectory();
     try {

       final bytes = file.readAsBytesSync();
       final archive = ZipDecoder().decodeBytes(bytes);
       for (final file in archive) {
         final filename = file.name;
         if (file.isFile) {
           final data = file.content as List<int>;
           File('${directory.path}/backup/extracted/$filename')
             ..createSync(recursive: true)
             ..writeAsBytesSync(data);
         }
       }

       file = File(
         '${directory.path}/backup/extracted/subscriptions_selected.json',
       );
       var content = await file.readAsString();
       List decoded = jsonDecode(content);
       List<UserSubscription> subscriptions =
       decoded.map((e) => UserSubscription.fromJson(e)).toList();
       for (var subscription in subscriptions) {
         if (SubscriptionPref.selectedSubscriptions
             .contains(subscription)) {
           continue;
         }
         SubscriptionPref.selectedSubscriptions =
         SubscriptionPref.selectedSubscriptions..add(subscription);
       }

       file = File(
         '${directory.path}/backup/extracted/subscriptions_custom.json',
       );
       content = await file.readAsString();
       decoded = jsonDecode(content);
       subscriptions =
           decoded.map((e) => UserSubscription.fromJson(e)).toList();
       for (var subscription in subscriptions) {
         if (SubscriptionPref.customSubscriptions
             .contains(subscription)) {
           continue;
         }
         SubscriptionPref.customSubscriptions =
         SubscriptionPref.customSubscriptions..add(subscription);
       }
       return true;
     } catch (e) {
       return false;
     } finally {
       await File("${directory.path}/backup/extracted").delete(recursive: true);
     }
  }

  void showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
    ));
  }

  Future<void> requestStoragePermission() async {
    if (Internal.sdkVersion >= 33) {
      await Permission.manageExternalStorage.request();
    } else {
      await Permission.storage.request();
    }
  }
}
