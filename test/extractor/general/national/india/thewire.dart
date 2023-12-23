import 'package:flutter_test/flutter_test.dart';
import 'package:whapp/extractor/general/national/india/thewire.dart';
import 'package:whapp/model/article.dart';

void main() {
  test('The Wire - Extract Categories Test', () async {
    final theWire = TheWire();

    final categories = await theWire.categories;

    expect(categories, isA<Map<String, String>>());
    expect(categories.isNotEmpty, true);
  });

  test('The Wire - Article Test', () async {
    final theWire = TheWire();

    const articleUrl = '/dont-marry-a-brit-unless-theyre-really-rich';
    final article = await theWire.article(articleUrl);

    expect(article, isA<NewsArticle>());
    expect(article?.title, isNotEmpty);
    expect(article?.content, isNotEmpty);
  });

  test('The Wire - Category Articles Test', () async {
    final theWire = TheWire();

    final categoryArticles =
        await theWire.categoryArticles(category: 'category/politics', page: 1);

    expect(categoryArticles, isA<Set<NewsArticle?>>());
    expect(categoryArticles, isNotEmpty);
  });

  test('The Wire - Search Articles Test', () async {
    final theWire = TheWire();

    final searchArticles =
        await theWire.searchedArticles(searchQuery: 'delhi', page: 1);

    expect(searchArticles, isA<Set<NewsArticle?>>());
    expect(searchArticles, isNotEmpty);
  });
}
