import 'package:device_info_plus/device_info_plus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:raven/model/user_subscription.dart';
import 'package:raven/provider/article.dart';
import 'package:raven/provider/search.dart';
import 'package:raven/provider/theme.dart';
import 'package:raven/repository/store.dart';
import 'package:raven/screen/home.dart';

import 'model/article.dart';
import 'provider/category_search.dart';
import 'provider/navigation.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter<UserSubscription>(UserSubscriptionAdapter());
  Hive.registerAdapter<Article>(ArticleAdapter());
  await Hive.openBox('settings');
  await Hive.openBox('saved');
  await Hive.openBox('offline-articles');
  await Hive.openBox('subscriptions');

  if (Store.sdkVersion == -1) {
    await DeviceInfoPlugin().androidInfo.then((value) {
      Store.sdkVersion = value.version.sdkInt;
    });
  }

  if (Store.appDirectory.isEmpty) {
    Store.appDirectory = (await getApplicationCacheDirectory()).path;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => ArticleProvider(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => ArticleSearchProvider(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => NavigationProvider(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => CategorySearchProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Store.settings.listenable(),
      builder: (context, box, child) {
        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: const MyHomePage(),
              theme: ThemeProvider().getCurrentTheme(
                lightScheme: lightDynamic,
                darkScheme: darkDynamic,
              ),
            );
          },
        );
      },
    );
  }
}
