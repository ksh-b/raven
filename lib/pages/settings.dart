import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:raven/api/simplytranslate.dart';
import 'package:raven/extractor/trend/google.dart';
import 'package:raven/model/trends.dart';
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
            child: Text(
              'Theme',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            secondary: Icon(Icons.brightness_6_rounded),
            title: Text('Dark Mode'),
            value: Store.darkThemeSetting,
            onChanged: (value) {
              Store.darkThemeSetting = value;
            },
          ),
          ListTile(
            leading: Icon(Icons.format_paint_rounded),
            title: Text('Color'),
            subtitle: Text(Store.themeColorSetting),
            onTap: () {
              _showPopup(
                context,
                "Color",
                (String option) {
                  Store.themeColorSetting = option;
                },
                ThemeProvider().colorOptions(),
              );
            },
          ),
          SizedBox(height: 20),
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
            child: Text(
              'Article',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.image),
            title: Text('Load images'),
            value: Store.loadImagesSetting,
            onChanged: (bool value) {
              Store.loadImagesSetting = value;
            },
          ),
          ListTile(
            leading: Icon(Icons.alt_route_rounded),
            title: Text('Alternate URL (Long tap)'),
            subtitle: Text(Store.ladderSetting),
            onTap: () {
              _showPopup(
                context,
                "Ladder",
                (String option) {
                  Store.ladderSetting = option;
                },
                Store.ladders.keys.toList(),
              );
            },
          ),
          SwitchListTile(
            secondary: Icon(Icons.translate_rounded),
            title: Text('Translate'),
            subtitle: Text('simplytranslate.org'),
            value: Store.shouldTranslate,
            onChanged: (value) {
              setState(() {
                Store.shouldTranslate = value;
              });
            },
          ),
          Store.shouldTranslate
              ? ListTile(
                  leading: Icon(Icons.language_rounded),
                  title: Text('Translate language'),
                  subtitle: Text(Store.languageSetting),
                  onTap: () {
                    _showPopup(
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
          SizedBox(height: 20),
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
            child: Text(
              'Search',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: Icon(Icons.trending_up_rounded),
            title: Text('Suggestions provider'),
            subtitle: Text(Store.trendsProviderSetting),
            onTap: () {
              _showPopup(
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
                  leading: Icon(Icons.location_on_rounded),
                  onTap: () {
                    _showPopup(context, "Trends Provider", (String option) {
                      Store.countrySetting = option;
                    }, GoogleTrend.locations);
                  },
                  title: Text("Google Trends location"),
                  subtitle: Text(Store.countrySetting),
                )
              : SizedBox.shrink(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

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
            return ListView(
              children: [themeSection(), articleSection(), searchSection()],
            );
          },
        ),
      ),
    );
  }

  void _showPopup(BuildContext context, String title, Function callback,
      List<String> options) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OptionsPopup(
          title: title,
          callback: callback,
          options: options,
        );
      },
    );
  }
}

class OptionsPopup extends StatefulWidget {
  final String title;
  final Function callback;
  final List<String> options;

  const OptionsPopup({
    super.key,
    required this.title,
    required this.callback,
    required this.options,
  });

  @override
  State<OptionsPopup> createState() => _OptionsPopupState();
}

class _OptionsPopupState extends State<OptionsPopup> {
  late List<String> filteredOptions;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    filteredOptions = widget.options;
    searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Container(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: ListBody(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: filteredOptions.length+1,
                itemBuilder: (BuildContext context, int index) {
                  if(index==0) {
                    return widget.options.length>5?TextField(
                      onChanged: _filterOptions,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                    ):SizedBox.shrink();
                  }
                  return ListTile(
                    title: Text(filteredOptions[index-1]),
                    onTap: () {
                      widget.callback(filteredOptions[index-1]);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _filterOptions(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredOptions = widget.options;
      } else {
        filteredOptions = widget.options
            .where((entry) => entry.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }
}
