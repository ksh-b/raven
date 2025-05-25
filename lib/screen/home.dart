import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raven/provider/navigation.dart';
import 'package:raven/provider/theme.dart';
import 'package:raven/screen/bookmarks.dart';
import 'package:raven/screen/feed.dart';
import 'package:raven/screen/saved.dart';
import 'package:raven/screen/settings/settings.dart';
import 'package:raven/screen/subscriptions.dart';
import 'package:raven/screen/watch.dart';
import 'package:raven/widget/search_delegate.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map pageNames = {
    0: "Feed",
    1: "Bookmarks",
    2: "Saved",
    3: "Subscriptions",
    4: "Settings",
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (BuildContext context, NavigationProvider nav, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(pageNames[nav.index]),
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: MySearchDelegate(),
                  );
                },
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemeProvider().getCurrentTheme().cardColor,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      visualDensity: VisualDensity.compact,
                      leading: CircleAvatar(
                        child: Icon(
                          Icons.person_rounded,
                        ),
                      ),
                      title: Text("Raven"),
                    ),
                  ),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.article),
                  title: Text("Feed"),
                  onTap: () {
                    nav.index = 0;
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.bookmark),
                  title: Text('Bookmarks'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BookmarksPage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.download_rounded),
                  title: Text('Saved'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SavedPage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.favorite_rounded),
                  title: Text('Subscriptions'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SubscriptionsPage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings_rounded),
                  title: Text('Settings'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          body: IndexedStack(
            index: nav.index,
            children: const [
              FeedPage(),
              SavedPage(),
              SubscriptionsPage(),
              SettingsPage(),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
