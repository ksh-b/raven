import 'package:flutter_test/flutter_test.dart';
import 'package:whapp/model/article.dart';
import 'package:whapp/model/publisher.dart';

class ExtractorTest {
  static Future<void> categoriesTest(Publisher publisher) async {
    final categories = await publisher.categories;

    expect(categories, isA<Map<String, String>>());
    expect(categories.isNotEmpty, true);
  }

  static Future<void> categoryArticlesTest(Publisher publisher) async {
    final Map<String, String> categories = await publisher.categories;
    final categoryArticles = await publisher.categoryArticles(category: categories.entries.first.value, page: 1);

    expect(categoryArticles, isNotEmpty);

    var article = categoryArticles.first;
    expect(article, isA<NewsArticle>());
    expect(article?.title, isNotEmpty);
    expect(article?.publishedAt.value, isNot(0));
  }

  static Future<void> searchedArticlesTest(Publisher publisher, String query) async {
    if (publisher.hasSearchSupport) {
      final searchArticles =
      await publisher.searchedArticles(searchQuery: query, page: 1);

      expect(searchArticles, isNotEmpty);

      var article = searchArticles.first;
      expect(article, isA<NewsArticle>());
      expect(article?.title, isNotEmpty);
      expect(article?.publishedAt.value, isNot(0));
    }
  }
}