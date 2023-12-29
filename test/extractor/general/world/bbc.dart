import 'package:flutter_test/flutter_test.dart';
import 'package:whapp/extractor/general/world/bbc.dart';
import 'package:whapp/model/article.dart';

void main() {
  test('BBC - Extract Categories Test', () async {
    final bbc = BBC();

    final categories = await bbc.categories;

    expect(categories, isA<Map<String, String>>());
    expect(categories.isNotEmpty, true);
  });

  test('BBC - Article Test', () async {
    final bbc = BBC();

    final articleUrl = '/news/world-asia-67825665';
    final article = await bbc.article(articleUrl);

    expect(article, isA<NewsArticle>());
    expect(article?.title, isNotEmpty);
    expect(article?.content, isNotEmpty);
    expect(article?.publishedAt.value, isNot(0));
  });

  test('BBC - Category Articles Test', () async {
    final bbc = BBC();

    var categoryArticles =
    await bbc.categoryArticles(category: 'world', page: 1);

    expect(categoryArticles, isA<Set<NewsArticle?>>());
    expect(categoryArticles, isNotEmpty);

    categoryArticles =
    await bbc.categoryArticles(category: 'technology', page: 1);
    expect(categoryArticles, isA<Set<NewsArticle?>>());
    expect(categoryArticles, isNotEmpty);
  });

  test('BBC - Searched Articles Test', () async {
    final bbc = BBC();

    final searchedArticles =
    await bbc.searchedArticles(searchQuery: 'climate', page: 1);

    expect(searchedArticles, isA<Set<NewsArticle?>>());
    expect(searchedArticles, isNotEmpty);
  });
}