import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/material.dart';
import 'package:raven/provider/theme.dart';
import 'package:raven/repository/preferences/internal.dart';
import 'package:raven/repository/store.dart';
import 'package:raven/repository/trends.dart';
import 'package:raven/service/simplytranslate.dart';
import 'package:raven/widget/options_popup.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Data'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.upload_rounded),
            title: const Text('Export'), // TODO
          ),
          ListTile(
            leading: const Icon(Icons.download_rounded),
            title: const Text('Import'), // TODO
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_rounded),
            title: const Text('Logs'), // TODO
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
}
