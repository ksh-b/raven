import 'package:flutter/material.dart';
import 'package:raven/provider/theme.dart';
import 'package:raven/repository/preferences/appearance.dart';
import 'package:raven/repository/store.dart';
import 'package:raven/widget/options_popup.dart';

class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key});

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: ListView(
        children: [
          ListTile(
            subtitle: Text("Theme"),
          ),
          ListTile(
            leading: Icon(Icons.brightness_6_rounded),
            title: Text("Base Theme"),
            subtitle: Text(AppearancePref.theme.toString()), // TODO: change text
            trailing: DropdownMenu<String>(
              initialSelection: AppearancePref.theme,
              onSelected: (String? value) {
                if(value==null) {
                  return;
                }
                setState(() {
                  AppearancePref.theme = value;
                });
              },
              dropdownMenuEntries: ThemePref
              .values.map((e) => e.name)
              .map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(value: value, label: value);
              }).toList(),
            ),
            // TODO: implement 'follow device theme'
          ),
          SwitchListTile(
            secondary: Icon(Icons.wallpaper_rounded),
            title: Text("Material You"),
            value: AppearancePref.materialYou,
            onChanged: (bool value) {
              setState(() {
                AppearancePref.materialYou = value;
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.palette_rounded),
            title: Text("Color"),
            subtitle: Text(AppearancePref.color.toString()),
            onTap: () {
              showPopup(
                context,
                "Color",
                    (String option) {
                  setState(() {

                    AppearancePref.color = option;
                  });
                },
                ThemeProvider().colorOptions(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.format_size_rounded),
            title: const Text('Font size'),
            subtitle: SliderTheme(
              data: const SliderThemeData(
                showValueIndicator: ShowValueIndicator.onlyForContinuous,
              ),
              child: Slider(
                value: AppearancePref.fontSize.toDouble(),
                min: 0.8,
                max: 1.5,
                divisions: 7,
                label: (AppearancePref.fontSize * 100).round().toString(),
                onChanged: (double value) {
                  setState(() {
                    AppearancePref.fontSize = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
