import 'package:flutter/material.dart';
import 'package:raven/screen/settings/appearance.dart';
import 'package:raven/screen/settings/content.dart';
import 'package:raven/screen/settings/about.dart';
import 'package:raven/screen/settings/data.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.palette_rounded),
            title: Text("Appearance"),
            subtitle: Text("Theme, Font size"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return const AppearancePage();
                }),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.change_circle_rounded),
            title: Text("Content"),
            subtitle: Text("Translations, Content Filter"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return const ContentPage();
                }),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.android_rounded),
            title: Text("App data"),
            subtitle: Text("Logs, Import/Export data"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return const DataPage();
                }),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help_rounded),
            title: Text("About"),
            subtitle: Text("Licences, Report issue"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return const AboutPage();
                }),
              );
            },
          ),
        ],
      )
      // body: Padding(
      //   padding: const EdgeInsets.only(left: 16, right: 16),
      //   child: ValueListenableBuilder(
      //     valueListenable: Store.settings.listenable(),
      //     builder: (context, box, child) {
      //       return ListView(
      //         children: [
      //           themeSection(),
      //           articleSection(),
      //           searchSection(),
      //           ListTile(
      //             leading: const Icon(Icons.info_outline_rounded),
      //             title: const Text('About'),
      //             onTap: () {
      //               PackageInfo.fromPlatform().then((packageInfo) {
      //                 showAboutDialog(
      //                   context: context,
      //                   applicationName: packageInfo.appName,
      //                   applicationVersion: packageInfo.version,
      //                 );
      //               });
      //             },
      //           ),
      //           ListTile(
      //             leading: const Icon(Icons.auto_delete_rounded),
      //             title: const Text('Clean cache'),
      //             onTap: () {
      //               HiveCacheStore(Store.appDirectory).clean();
      //             },
      //           ),
      //         ],
      //       );
      //     },
      //   ),
      // ),
    );
  }
}
