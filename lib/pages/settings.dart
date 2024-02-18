import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:whapp/api/simplytranslate.dart';
import 'package:whapp/utils/store.dart';
import 'package:whapp/utils/theme_provider.dart';

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
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder(
          valueListenable: Store.settings.listenable(),
          builder: (context, box, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SwitchListTile(
                  title: Text('Dark Mode'),
                  value: Store.darkThemeSetting,
                  onChanged: (value) {
                    Store.darkThemeSetting = value;
                  },
                ),
                ListTile(
                  title: Text('Color'),
                  trailing: DropdownButton<String>(
                    value: Store.themeColorSetting,
                    onChanged: (String? color) {
                      if(color!=null) {
                        Store.themeColorSetting = color;
                      }
                    },
                    items: ThemeProvider.colors.keys.map<DropdownMenuItem<String>>((String color) {
                      return DropdownMenuItem<String>(
                        value: color,
                        child: Text(color),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Article',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ListTile(
                  title: Text('Load images'),
                  trailing: DropdownButton<String>(
                    value: Store.loadImagesSetting,
                    onChanged: (String? option) {
                      if(option!=null) {
                        Store.loadImagesSetting = option;
                      }
                    },
                    items: Store.loadImagesValues.map<DropdownMenuItem<String>>((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                  ),
                ),
                ListTile(
                  title: Text('Redirection'),
                  subtitle: Text('Alternate URLs (Long tap)'),
                  trailing: DropdownButton<String>(
                    value: Store.ladderSetting,
                    onChanged: (String? option) {
                      if(option!=null) {
                        Store.ladderSetting = option;
                      }
                    },
                    items: Store.ladders.keys.map<DropdownMenuItem<String>>((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                  ),
                ),
                SwitchListTile(
                  title: Text('Translate'),
                  value: Store.translate,
                  onChanged: (value) {
                    setState(() {
                      Store.translate = value;
                    });
                  },
                ),
                ListTile(
                  title: Text('Translate language'),
                  trailing: DropdownButton<String>(
                    value: Store.language,
                    onChanged: Store.translate? (String? option) {
                      if(option!=null) {
                        Store.languageSetting = option;
                      }
                    }:null,
                    items: SimplyTranslate().languages.keys.map<DropdownMenuItem<String>>((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}