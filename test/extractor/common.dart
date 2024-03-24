import 'package:flutter_test/flutter_test.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';

class ExtractorTest {
  static Future<void> categoriesTest(Publisher publisher) async {
    final categories = await publisher.categories;

    expect(categories, isA<Map<String, String>>());
    expect(categories.isNotEmpty, true);
  }

  static Future<void> categoryArticlesTest(Publisher publisher, {String? category}) async {
    if(category==null) {
      final Map<String, String> categories = await publisher.categories;

      for(String category in categories.values) {
        expect(category, isNotNull);
        final categoryArticles = await publisher.categoryArticles(category: category, page: 1);

        expect(categoryArticles, isNotEmpty, reason: category);

        var article = categoryArticles.first;
        expect(article, isNotNull);
        expect(article, isA<NewsArticle>());
        expect(article.title, isNotEmpty);
        if (article.publishedAt.key==0){
          print("date format issue ${article.publishedAt.key}");
        }

        var articleFull = await publisher.article(article);
        expect(articleFull, isNotNull);
        if(articleFull.content.isEmpty) {
          print("Content was empty\n$article");
        }
      }

    }

  }

  static Future<void> searchedArticlesTest(Publisher publisher, String query) async {
    if (publisher.hasSearchSupport) {
      final searchArticles =
      await publisher.searchedArticles(searchQuery: query, page: 1);

      expect(searchArticles, isNotEmpty);

      var article = searchArticles.first;
      expect(article, isA<NewsArticle>());
      expect(article?.title, isNotEmpty);
      expect(article?.publishedAt.key, isNot(0), reason: article?.publishedAt.value);

      var articleFull = await publisher.article(article!);
      expect(articleFull, isNotNull);
      expect(articleFull?.content, isNotEmpty);
    }
  }
}