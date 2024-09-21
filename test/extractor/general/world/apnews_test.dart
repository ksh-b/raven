import 'package:test/test.dart';
import 'package:raven/repository/news/general/world/apnews.dart';
import 'package:raven/model/publisher.dart';

import '../../common.dart';

void main() {
  Publisher publisher = APNews();

  test('Extract Categories Test', () async {
    await ExtractorTest.categoriesTest(publisher);
  });

  test('Category Articles Test', () async {
    await ExtractorTest.categoryArticlesTest(publisher, ignoreDateCheck: true);
  });

  test('Search Articles Test', () async {
    await ExtractorTest.searchedArticlesTest(publisher, 'world');
  });
}
