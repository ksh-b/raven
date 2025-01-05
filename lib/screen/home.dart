import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raven/provider/navigation.dart';
import 'package:raven/screen/bookmarks.dart';
import 'package:raven/screen/feed.dart';
import 'package:raven/screen/saved.dart';
import 'package:raven/screen/settings/settings.dart';
import 'package:raven/screen/subscriptions.dart';
import 'package:raven/screen/watch.dart';

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
    4: "Widgets",
    5: "Settings",
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
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                DrawerHeader(
                  child: Text('Hello'),
                ),
                ListTile(
                  leading: Icon(Icons.article),
                  title: Text('Feed'),
                  onTap: () {
                    nav.index = 0;
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.bookmark),
                  title: Text('Bookmarks'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const BookmarksPage()),);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.download_rounded),
                  title: Text('Saved'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedPage()),);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.favorite_rounded),
                  title: Text('Subscriptions'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionsPage()),);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.show_chart_rounded),
                  title: Text('Widgets'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WatchPage()),);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings_rounded),
                  title: Text('Settings'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()),);
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
