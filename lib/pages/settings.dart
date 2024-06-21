import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:raven/extractor/trend/google.dart';
import 'package:raven/extractor/trend/yahoo.dart';
import 'package:raven/model/trends.dart';
import 'package:raven/pages/widget/options_popup.dart';
import 'package:raven/service/simplytranslate.dart';
import 'package:raven/utils/store.dart';
import 'package:raven/utils/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Widget themeSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Theme',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.brightness_6_rounded),
            title: const Text('Dark Mode'),
            value: Store.darkThemeSetting,
            onChanged: (value) {
              Store.darkThemeSetting = value;
            },
          ),
          ListTile(
            leading: const Icon(Icons.format_paint_rounded),
            title: const Text('Color'),
            subtitle: Text(Store.themeColorSetting),
            onTap: () {
              showPopup(
                context,
                "Color",
                (String option) {
                  Store.themeColorSetting = option;
                },
                ThemeProvider().colorOptions(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.format_size_rounded),
            title: const Text('Font size'),
            subtitle: SliderTheme(
              data: SliderThemeData(
                  showValueIndicator: ShowValueIndicator.onlyForContinuous,),
              child: Slider(
                value: Store.fontScale,
                min: 0.8,
                max: 1.5,
                // divisions: 7,
                label: (Store.fontScale * 100).round().toString(),
                onChanged: (double value) {
                  setState(() {
                    Store.fontScale = value;
                  });
                },

              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget articleSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Article',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.image),
            title: const Text('Load images'),
            value: Store.loadImagesSetting,
            onChanged: (bool value) {
              Store.loadImagesSetting = value;
            },
          ),
          ListTile(
            leading: const Icon(Icons.linear_scale),
            title: const Text('Max articles per subscription'),
            subtitle: SliderTheme(
              data: SliderThemeData(
                showValueIndicator: ShowValueIndicator.onlyForContinuous,),
              child: Slider(
                value: Store.articlesPerSub * 1.0,
                min: 5,
                max: 30,
                label: Store.articlesPerSub.toString(),
                onChanged: (double value) {
                  setState(() {
                    Store.articlesPerSub = value.toInt();
                  });
                },
              ),
            ),
          ),
          SwitchListTile(
            secondary: Icon(Icons.translate_rounded),
            title: const Text('Translate'),
            value: Store.shouldTranslate,
            onChanged: (value) {
              setState(() {
                Store.shouldTranslate = value;
              });
            },
          ),
          Store.shouldTranslate
              ? ListTile(
                  title: const Text('Translator'),
                  subtitle: Text(Store.translatorSetting),
                  enabled: false,
                )
              : SizedBox.shrink(),
          Store.shouldTranslate
              ? ListTile(
                  title: const Text('Translate language'),
                  subtitle: Text(Store.languageSetting),
                  onTap: () {
                    showPopup(
                      context,
                      "Translate language",
                      (String option) {
                        Store.languageSetting = option;
                      },
                      SimplyTranslate().languages.keys.toList(),
                    );
                  },
                )
              : SizedBox.shrink(),
          Store.shouldTranslate
              ? ListTile(
                  title: const Text('Translator instance'),
                  subtitle: Text(Store.translatorInstanceSetting),
                  onTap: () {
                    showPopup(
                      context,
                      "Translator instance",
                      (String option) {
                        Store.translatorInstanceSetting = option;
                        Store.translatorEngineSetting = SimplyTranslate()
                            .instances[Store.translatorInstanceSetting]!
                            .first;
                      },
                      SimplyTranslate().instances.keys.toList(),
                    );
                  },
                )
              : SizedBox.shrink(),
          Store.shouldTranslate
              ? ListTile(
                  title: const Text('Translator engine'),
                  subtitle: Text(Store.translatorEngineSetting),
                  onTap: () {
                    showPopup(
                      context,
                      "Translate engine",
                      (String option) {
                        Store.translatorEngineSetting = option;
                      },
                      SimplyTranslate()
                          .instances[Store.translatorInstanceSetting]!,
                    );
                  },
                  enabled: false,
                )
              : const SizedBox.shrink(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget searchSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Search',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.trending_up_rounded),
            title: const Text('Suggestions provider'),
            subtitle: Text(Store.trendsProviderSetting),
            onTap: () {
              showPopup(
                context,
                "Suggestions provider",
                (String option) {
                  Store.trendsProviderSetting = option;
                },
                trends.keys.toList(),
              );
            },
          ),
          Store.trendsProviderSetting == "Google"
              ? ListTile(
                  leading: const Icon(Icons.location_on_rounded),
                  onTap: () {
                    showPopup(context, "Trends Provider", (String option) {
                      Store.countrySetting = option;
                    }, GoogleTrend.locations);
                  },
                  title: Text("Google Trends location"),
                  subtitle: Text(Store.countrySetting),
                )
              : const SizedBox.shrink(),
          Store.trendsProviderSetting == "Yahoo"
              ? ListTile(
                  leading: const Icon(Icons.location_on_rounded),
                  onTap: () {
                    showPopup(context, "Trends Provider", (String option) {
                      Store.countrySetting = option;
                    }, YahooTrend.locations);
                  },
                  title: Text("Yahoo Trends location"),
                  subtitle: Text(Store.countrySetting),
                )
              : const SizedBox.shrink(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: ValueListenableBuilder(
          valueListenable: Store.settings.listenable(),
          builder: (context, box, child) {
            return ListView(
              children: [
                themeSection(),
                articleSection(),
                searchSection(),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('About'),
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
              ],
            );
          },
        ),
      ),
    );
  }

}
