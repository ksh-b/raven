import 'package:flutter/material.dart';
import 'package:raven/pages/feed.dart';
import 'package:raven/pages/saved.dart';
import 'package:raven/pages/settings.dart';
import 'package:raven/pages/subscription.dart';
import 'package:raven/utils/store.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        labelBehavior: Store.fontScale > 1
            ? NavigationDestinationLabelBehavior.alwaysHide
            : NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: _selectedIndex,
        destinations: <Widget>[
          const NavigationDestination(
            icon: const Icon(Icons.article_outlined),
            selectedIcon: const Icon(Icons.article),
            label: 'Feed',
          ),
          const NavigationDestination(
            icon: const Icon(Icons.bookmark_outline_rounded),
            selectedIcon: const Icon(Icons.bookmark_rounded),
            label: 'Saved',
          ),
          const NavigationDestination(
            icon: const Icon(Icons.favorite_border_rounded),
            selectedIcon: const Icon(Icons.favorite_rounded),
            label: 'Subscriptions',
          ),
          const NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const FeedPage(),
          const SavedPage(),
          const SubscriptionsPage(),
          const SettingsPage(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
