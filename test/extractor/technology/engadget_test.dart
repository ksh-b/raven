import 'package:test/test.dart';
import 'package:raven/repository/news/technology/engadget.dart';
import 'package:raven/model/publisher.dart';

import '../common.dart';

void main() {
  Publisher publisher = Engadget();

  test('Extract Categories Test', () async {
    await ExtractorTest.categoriesTest(publisher);
  });

  test('Category Articles Test', () async {
    await ExtractorTest.categoryArticlesTest(publisher, category: "/news",ignoreDateCheck: true);
  });

  test('Search Articles Test', () async {
    await ExtractorTest.searchedArticlesTest(publisher, 'tech', ignoreDateCheck: true);
  });
}
