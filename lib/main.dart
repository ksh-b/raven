import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:whapp/model/user_subscription.dart';
import 'package:whapp/pages/home.dart';
import 'package:whapp/utils/theme_provider.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(UserSubscriptionAdapter());
  await Hive.openBox('subscriptions');
  await Hive.openBox('settings');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, box, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MyHomePage(),
          theme: ThemeProvider.get(
            ThemeProvider.colors[box.get('themeColor', defaultValue: ThemeProvider.defaultColor)]!,
            box.get('darkMode', defaultValue: false),
          ),
        );
      },
    );
  }
}
