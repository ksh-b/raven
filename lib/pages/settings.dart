import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:whapp/utils/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<String> loadImagesValues = ["Always", "Never", "Auto"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder(
          valueListenable: Hive.box("settings").listenable(),
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
                  value: box.get("darkMode", defaultValue: false),
                  onChanged: (value) {
                    setState(() {
                      box.put("darkMode", value);
                    });
                  },
                ),
                ListTile(
                  title: Text('Color'),
                  trailing: DropdownButton<String>(
                    value: box.get("themeColor", defaultValue: ThemeProvider.defaultColor),
                    onChanged: (String? color) {
                      if(color!=null) {
                        box.put("themeColor", color);
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
                  'Network',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ListTile(
                  title: Text('Load article images'),
                  trailing: DropdownButton<String>(
                    value: box.get("loadImages", defaultValue: "Always"),
                    onChanged: (String? option) {
                      if(option!=null) {
                        box.put("loadImages", option);
                      }
                    },
                    items: loadImagesValues.map<DropdownMenuItem<String>>((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}