import 'package:flutter_test/flutter_test.dart';
import 'package:whapp/extractor/general/world/reuters.dart';
import 'package:whapp/model/article.dart';

void main() {
  test('Reuters - Extract Categories Test', () async {
    final reuters = Reuters();

    final categories = await reuters.categories;

    expect(categories, isA<Map<String, String>>());
    expect(categories.isNotEmpty, true);
  });

  test('Reuters - Article Test', () async {
    final reuters = Reuters();

    final articleUrl = '/world/us/senators-move-require-release-us-government-ufo-records-2023-07-14/';
    final article = await reuters.article(articleUrl);

    expect(article, isA<NewsArticle>());
    expect(article?.title, isNotEmpty);
    expect(article?.content, isNotEmpty);
    expect(article?.publishedAt.value, isNot(0));
  });

  test('Reuters - Category Articles Test', () async {
    final reuters = Reuters();

    final categoryArticles =
        await reuters.categoryArticles(category: 'business', page: 1);

    expect(categoryArticles, isA<Set<NewsArticle?>>());
    expect(categoryArticles, isNotEmpty);
  });

  test('Reuters - Searched Articles Test', () async {
    final reuters = Reuters();

    final searchedArticles =
        await reuters.searchedArticles(searchQuery: 'ufo', page: 1);

    expect(searchedArticles, isA<Set<NewsArticle?>>());
    expect(searchedArticles, isNotEmpty);
  });
}
