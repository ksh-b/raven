import 'package:flutter_test/flutter_test.dart';
import 'package:whapp/extractor/general/world/nitter.dart';
import 'package:whapp/extractor/technology/engadget.dart';
import 'package:whapp/model/article.dart';
import 'package:whapp/model/publisher.dart';

import '../../common.dart';

void main() {
  Publisher publisher = Nitter();

  test('Extract Categories Test', () async {
    await ExtractorTest.categoriesTest(publisher);
  });

  test('Category Articles Test', () async {
    final categoryArticles = await publisher.categoryArticles(category: "Steam", page: 1);

    expect(categoryArticles, isNotEmpty);

    var article = categoryArticles.first;
    expect(article, isA<NewsArticle>());
    expect(article?.title, isNotEmpty);
    expect(article?.publishedAt.value, isNot(0));
  });

  test('Search Articles Test', () async {
    await ExtractorTest.searchedArticlesTest(publisher, 'Steam#sale');
  });
}
