import 'dart:io';

import 'package:test/test.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';

class ExtractorTest {
  static Future<void> categoriesTest(Publisher publisher) async {
    final categories = await publisher.categories;

    expect(categories, isA<Map<String, String>>());
    expect(categories.isNotEmpty, true);
  }

  static Future<void> categoryArticlesTest(Publisher publisher,
      {String? category, bool skipDateCheck=false}) async {
    if (category == null) {
      final Map<String, String> categories = await publisher.categories;

      for (String category in categories.values) {
        sleep(Duration(seconds: 2));
        print(category);
        expect(category, isNotNull);
        final categoryArticles =
            await publisher.categoryArticles(category: category, page: 1);

        expect(categoryArticles, isNotEmpty, reason: category);

        var article = categoryArticles.first;
        expect(article, isNotNull);
        expect(article, isA<NewsArticle>());
        expect(article.title, isNotEmpty, reason: "$article");

        await publisher.article(article).then((value) {
          print(article);
          expect(value, isNotNull);
          expect(value.publishedAt, isNonNegative, reason: article.url, skip: skipDateCheck);
          expect(value.content, isNotEmpty, reason: article.url);
        },);
      }
    }
  }

  static Future<void> searchedArticlesTest(
      Publisher publisher, String query, {bool ignoreDateCheck=false}) async {
    if (publisher.hasSearchSupport) {
      final searchArticles =
          await publisher.searchedArticles(searchQuery: query, page: 1);

      expect(searchArticles, isNotEmpty);

      var article = searchArticles.first;
      print("<<<$article>>>");
      expect(article, isA<NewsArticle>());
      expect(article.title, isNotEmpty);
      expect(article.publishedAt, isNot(-1),
          reason: article.publishedAt.toString(), skip: ignoreDateCheck);

      var articleFull = await publisher.article(article);
      expect(articleFull, isNotNull);
      expect(articleFull.content, isNotEmpty);
    }
  }
}
