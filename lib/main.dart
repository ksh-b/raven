import 'package:device_info_plus/device_info_plus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:raven/model/filter.dart';
import 'package:raven/model/source/source_dart.dart';
import 'package:raven/model/source/source_json.dart';
import 'package:raven/model/stored_repo.dart';
import 'package:raven/model/user_subscription.dart';
import 'package:raven/provider/article.dart';
import 'package:raven/provider/search.dart';
import 'package:raven/provider/theme.dart';
import 'package:raven/repository/git/github.dart';
import 'package:raven/repository/news/custom/json.dart';
import 'package:raven/repository/preferences/appearance.dart';
import 'package:raven/repository/preferences/content.dart';
import 'package:raven/repository/preferences/internal.dart';
import 'package:raven/screen/home.dart';

import 'model/article.dart';
import 'model/source/watch_dart.dart';
import 'model/watch.dart';
import 'model/watch_item_history.dart';
import 'provider/category_search.dart';
import 'provider/navigation.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter<UserFeedSubscription>(UserFeedSubscriptionAdapter());
  Hive.registerAdapter<Article>(ArticleAdapter());
  Hive.registerAdapter<Filter>(FilterAdapter());
  Hive.registerAdapter<ExternalSource>(ExternalSourceAdapter());
  Hive.registerAdapter<JsonSource>(JsonSourceAdapter());
  Hive.registerAdapter<Categories>(CategoriesAdapter());
  Hive.registerAdapter<Include>(IncludeAdapter());
  Hive.registerAdapter<Headers>(HeadersAdapter());
  Hive.registerAdapter<SourceArticle>(SourceArticleAdapter());
  Hive.registerAdapter<Locators>(LocatorsAdapter());
  Hive.registerAdapter<ExternalSourceMeta>(ExternalSourceMetaAdapter());
  Hive.registerAdapter<StoredRepo>(StoredRepoAdapter());
  Hive.registerAdapter<Watch>(WatchAdapter());
  Hive.registerAdapter<WatchImport>(WatchImportAdapter());
  Hive.registerAdapter<WatchItemHistory>(WatchItemHistoryAdapter());
  Hive.registerAdapter<Items>(ItemsAdapter());
  Hive.registerAdapter<Option>(OptionAdapter());
  Hive.registerAdapter<Ing>(IngAdapter());
  await Hive.openBox('settings');
  await Hive.openBox('bookmarks');
  await Hive.openBox('saved');
  await Hive.openBox('offline-articles');
  await Hive.openBox('subscriptions');
  await Hive.openBox<WatchItemHistory>("watch-subscriptions");
  if (Internal.sdkVersion == -1) {
    await DeviceInfoPlugin().androidInfo.then((value) {
      Internal.sdkVersion = value.version.sdkInt;
    });
  }

  if (Internal.appDirectory.isEmpty) {
    Internal.appDirectory = (await getApplicationCacheDirectory()).path;
  }

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle().copyWith(
      statusBarColor: ThemeProvider.colors[AppearancePref.color],
      systemNavigationBarColor: ThemeProvider.colors[AppearancePref.color],
    ),
  );

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
          create: (BuildContext context) => FeedSourceSearchProvider(),
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
      valueListenable: Internal.settings.listenable(),
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
