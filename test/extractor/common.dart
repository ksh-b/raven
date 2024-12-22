// import 'dart:io';
//
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:raven/model/article.dart';
// import 'package:raven/model/publisher.dart';
// import 'package:raven/model/user_subscription.dart';
// import 'package:raven/provider/fallback_provider.dart';
// import 'package:test/test.dart';
//
// class ExtractorTest {
//   static Future<void> categoriesTest(InternalSource publisher) async {
//     final categories = await publisher.categories;
//
//     expect(categories, isA<Map<String, String>>());
//     expect(categories.isNotEmpty, true);
//   }
//
//   static Future<void> categoryArticlesTest(
//     InternalSource publisher, {
//     String? category,
//     bool ignoreDateCheck = false,
//   }) async {
//
//     if (category == null) {
//       final Map<String, String> categories = await publisher.categories;
//
//       for (String category in categories.values) {
//         expect(category, startsWith('/'), reason: category);
//         await testCategory(category, publisher, ignoreDateCheck);
//       }
//     } else {
//       await testCategory(category, publisher, ignoreDateCheck);
//     }
//   }
//
//   static Future<void> testCategory(
//     String category,
//     InternalSource publisher,
//     bool skipDateCheck,
//   ) async {
//
//     sleep(Duration(seconds: 2));
//     print(category);
//     expect(category, isNotNull);
//     final categoryArticles =
//         await publisher.categoryArticles(category: category, page: 1);
//
//     expect(categoryArticles, isNotEmpty, reason: category);
//
//     var article = categoryArticles.first;
//     expect(article, isNotNull);
//     expect(article, isA<Article>());
//     expect(article.title, isNotEmpty, reason: "$article");
//
//     await publisher.article(article).then(
//       (value) async {
//         print(article);
//         expect(value, isNotNull);
//         expect(value.publishedAt, isNonNegative,
//             reason: article.url, skip: skipDateCheck);
//         if (value.content.isEmpty) {
//           await FallbackProvider().get(article).then((value) {
//             expect(value.content, isNotEmpty, reason: article.url);
//           });
//         } else {
//           expect(value.content, isNotEmpty, reason: article.url);
//         }
//       },
//     );
//   }
//
//   static Future<void> searchedArticlesTest(InternalSource publisher, String query,
//       {bool ignoreDateCheck = false}) async {
//     if (publisher.hasSearchSupport) {
//       final searchArticles =
//           await publisher.searchedArticles(searchQuery: query, page: 1);
//
//       expect(searchArticles, isNotEmpty);
//
//       var article = searchArticles.first;
//       print("<<<$article>>>");
//       expect(article, isA<Article>());
//       expect(article.title, isNotEmpty);
//       expect(article.publishedAt, isNot(-1),
//           reason: article.publishedAt.toString(), skip: ignoreDateCheck);
//
//       var articleFull = await publisher.article(article);
//       expect(articleFull, isNotNull);
//       expect(articleFull.content, isNotEmpty);
//     }
//   }
// }
