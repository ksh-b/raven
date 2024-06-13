import 'package:device_info_plus/device_info_plus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/user_subscription.dart';
import 'package:raven/pages/home.dart';
import 'package:raven/utils/store.dart';
import 'package:raven/utils/theme_provider.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(UserSubscriptionAdapter());
  Hive.registerAdapter(NewsArticleAdapter());
  await Hive.openBox('subscriptions');
  await Hive.openBox('settings');
  await Hive.openBox('saved');
  await Hive.openBox('offline-articles');

  // TODO: Remove this in future version
  Store.selectedSubscriptions = Store.selectedSubscriptions
    ..removeWhere(
      (element) {
        return
          element.toString() == "RSS Feed~/" ||
          element.toString() == "morss~/" ||
          element.toString() == "Ars Technica~";
      },
    );

  if (Store.sdkVersion == -1) {
    await DeviceInfoPlugin().androidInfo.then((value) {
      Store.sdkVersion = value.version.sdkInt;
    });
  }

  runApp(const MyApp());
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
              home: MyHomePage(),
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
