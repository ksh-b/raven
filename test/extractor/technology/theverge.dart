import 'package:flutter_test/flutter_test.dart';
import 'package:whapp/extractor/technology/theverge.dart';
import 'package:whapp/model/article.dart';

void main() {
  test('The Verge - Extract Categories Test', () async {
    final theVerge = TheVerge();

    final categories = await theVerge.categories;

    expect(categories, isA<Map<String, String>>());
    expect(categories.isNotEmpty, true);
  });

  test('The Verge - Article Test', () async {
    final theVerge = TheVerge();

    const articleUrl = '/2023/12/21/24011168/sony-playstation-discovery-shows-not-removed';
    final article = await theVerge.article(articleUrl);

    expect(article, isA<NewsArticle>());
    expect(article?.title, isNotEmpty);
    expect(article?.content, isNotEmpty);
  });

  test('The Verge - Category Articles Test', () async {
    final theVerge = TheVerge();

    final categoryArticles =
        await theVerge.categoryArticles(category: 'tech', page: 1);

    expect(categoryArticles, isA<Set<NewsArticle?>>());
    expect(categoryArticles, isNotEmpty);
  });

  test('The Verge - Search Articles Test', () async {
    final theVerge = TheVerge();

    final searchArticles =
        await theVerge.searchedArticles(searchQuery: 'playstation', page: 1);

    expect(searchArticles, isA<Set<NewsArticle?>>());
    expect(searchArticles, isNotEmpty);
  });
}
