import 'package:flutter/material.dart';
import 'package:raven/repository/preferences/content.dart';
import 'package:raven/repository/search_suggestions.dart';
import 'package:raven/repository/trends.dart';
import 'package:raven/screen/customize_filters.dart';
import 'package:raven/screen/subscriptions_provider.dart';
import 'package:raven/service/mlkit_translation.dart';
import 'package:raven/widget/options_popup.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content'),
      ),
      body: ListView(
        children: [
          ListTile(
            subtitle: Text("Subscription Providers"),
            visualDensity: VisualDensity.compact,
            dense: true,
          ),
          ListTile(
            leading: const Icon(Icons.public_rounded),
            title: const Text('Manage'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SubscriptionsManager()),
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.update),
            title: const Text('Auto update on app start'),
            onChanged: (value) {
              ContentPref.autoUpdate = value;
            },
            value: ContentPref.autoUpdate,
          ),
          Divider(),
          ListTile(
            subtitle: Text("Search Providers"),
            visualDensity: VisualDensity.compact,
            dense: true,
          ),
          ListTile(
            leading: const Icon(Icons.search_rounded),
            title: const Text('Suggestions'),
            subtitle: Text(ContentPref.searchSuggestionsProvider),
            onTap: () {
              showPopup(
                context,
                "Search suggestions provider",
                    (String option) {
                  setState(() {
                    ContentPref.searchSuggestionsProvider = option;
                  });
                },
                searchSuggestions.keys.toList(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.trending_up_rounded),
            title: const Text('Trends'),
            subtitle: Text(ContentPref.trendsProvider),
            onTap: () {
              showPopup(
                context,
                "Trends provider",
                (String option) {
                  setState(() {
                    ContentPref.trendsProvider = option;
                  });
                },
                trends.keys.toList(),
              );
            },
          ),
          ContentPref.trendsProvider != "None"
              ? ListTile(
                  leading: Icon(Icons.location_on_rounded),
                  title: Text("Location"),
                  subtitle: Text(ContentPref.country.toString()),
                  onTap: () {
                    showPopup(
                      context,
                      "Search suggestions location",
                      (String option) {
                        setState(() {
                          ContentPref.country = option;
                        });
                      },
                      trends[ContentPref.trendsProvider]!
                          .locations
                          .toList(),
                    );
                  },
                )
              : SizedBox.shrink(),
          Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.image),
            title: const Text('Load images'),
            value: ContentPref.shouldLoadImages,
            onChanged: (bool value) {
              setState(() {
                ContentPref.shouldLoadImages = value;
              });
            },
          ),
          Divider(),
          ListTile(
            subtitle: Text("Filter articles"),
            visualDensity: VisualDensity.compact,
            dense: true,
          ),
          InkWell(
            child: ListTile(
              leading: const Icon(Icons.filter_alt_rounded), // TODO
              title: const Text('Filter articles'),
              subtitle: const Text("Hide articles containing specified keywords"),
              trailing: Switch(
                value: ContentPref.shouldFilterContent,
                onChanged: (value) {
                  setState(() {
                    ContentPref.shouldFilterContent = value;
                  });
                },
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CustomizeFilters()),
              );
            },
          ),
          Divider(),
          ListTile(
            subtitle: Text("Translations"),
            visualDensity: VisualDensity.compact,
            dense: true,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.translate_rounded),
            title: const Text('Translate'),
            value: ContentPref.shouldTranslate,
            onChanged: (value) {
              setState(() {
                ContentPref.shouldTranslate = value;
              });
            },
          ),
          ListTile(
            title: const Text('Translator'),
            subtitle: Text(ContentPref.translator),
            enabled: false,
          ),
          ListTile(
            title: const Text('Translate language'),
            subtitle: Text(ContentPref.translateTo),
            onTap: () {
              showPopup(
                context,
                "Translate language",
                (String option) {
                  ContentPref.translateTo = option;
                },
                MLKitTranslation().languages().keys.toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
