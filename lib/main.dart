import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:whapp/model/user_subscription.dart';
import 'package:whapp/pages/home.dart';


Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(UserSubscriptionAdapter());
  await Hive.openBox('subscriptions');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner:false,
      home: MyHomePage(),
    );
  }
}
