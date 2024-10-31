import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:raven/provider/theme.dart';
import 'package:raven/repository/store.dart';
import 'package:raven/repository/trends.dart';
import 'package:raven/service/simplytranslate.dart';
import 'package:raven/widget/options_popup.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About'),
            subtitle: Text("Version and Licences"),
            onTap: () {
              PackageInfo.fromPlatform().then((packageInfo) {
                showAboutDialog(
                  context: context,
                  applicationName: packageInfo.appName,
                  applicationVersion: packageInfo.version,
                );
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_rounded),
            title: const Text('Github'),
            onTap: () {
              launchUrl(Uri.parse("https://github.com/ksh-b/raven"));
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_rounded),
            title: const Text('Report issue'),
            onTap: () {
              launchUrl(Uri.parse("https://github.com/ksh-b/raven/issues"));
            },
          ),
        ],
      ),
    );
  }
}
