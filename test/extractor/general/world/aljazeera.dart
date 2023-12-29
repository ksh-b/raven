import 'package:flutter_test/flutter_test.dart';
import 'package:whapp/extractor/general/world/aljazeera.dart';
import 'package:whapp/extractor/general/world/reuters.dart';
import 'package:whapp/model/article.dart';

void main() {

  late AlJazeera alJazeera;
  setUp(() {
    alJazeera = AlJazeera();
  });

  test('Al Jazeera - Categories Test', () async {
    final categories = await alJazeera.categories;

    expect(categories, isA<Map<String, String>>());
    expect(categories.isNotEmpty, true);
  });

  test('Al Jazeera - Article Test', () async {
    final articleUrl =
        '/news/2023/12/25/ukraine-russia-say-six-civilians-killed-in-attacks-on-kherson-horlivka';
    final article = await alJazeera.article(articleUrl);

    expect(article, isA<NewsArticle>());
    expect(article?.title, isNotEmpty);
    expect(article?.content, isNotEmpty);
    expect(article?.publishedAt.value, isNot(0));
  });

  test('Al Jazeera - Category Articles Test', () async {
    final categoryArticles =
    await alJazeera.categoryArticles(category: 'features', page: 1);

    expect(categoryArticles, isA<Set<NewsArticle?>>());
    expect(categoryArticles, isNotEmpty);
  });

  test('Al Jazeera - Searched Articles Test', () async {
    final searchedArticles =
    await alJazeera.searchedArticles(searchQuery: 'ukraine', page: 1);

    expect(searchedArticles, isA<Set<NewsArticle?>>());
    expect(searchedArticles, isNotEmpty);
  });
}
