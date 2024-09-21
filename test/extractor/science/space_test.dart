import 'package:raven/model/publisher.dart';
import 'package:raven/repository/news/science/space.dart';
import 'package:test/test.dart';

import '../common.dart';

void main() {
  Publisher publisher = Space();

  test('Extract Categories Test', () async {
    await ExtractorTest.categoriesTest(publisher);
  });

  test('Category Articles Test', () async {
    await ExtractorTest.categoryArticlesTest(publisher);
  });

  test('Search Articles Test', () async {
    await ExtractorTest.searchedArticlesTest(publisher, 'world');
  });
}
