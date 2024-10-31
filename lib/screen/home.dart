import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raven/provider/navigation.dart';
import 'package:raven/repository/preferences/appearance.dart';
import 'package:raven/repository/store.dart';
import 'package:raven/screen/feed.dart';
import 'package:raven/screen/saved.dart';
import 'package:raven/screen/settings/settings.dart';
import 'package:raven/screen/subscriptions.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (BuildContext context, NavigationProvider nav, Widget? child) {
        return Scaffold(
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) {
              nav.index = index;
            },
            labelBehavior: AppearancePref.fontSize > 1
                ? NavigationDestinationLabelBehavior.alwaysHide
                : NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: nav.index,
            destinations: const <Widget>[
              NavigationDestination(
                icon: Icon(Icons.article_outlined),
                selectedIcon: Icon(Icons.article),
                label: 'Feed',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_outline_rounded),
                selectedIcon: Icon(Icons.bookmark_rounded),
                label: 'Saved',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_border_rounded),
                selectedIcon: Icon(Icons.favorite_rounded),
                label: 'Subscriptions',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
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
