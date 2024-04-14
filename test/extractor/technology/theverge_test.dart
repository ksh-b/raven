import 'package:test/test.dart';
import 'package:raven/extractor/technology/theverge.dart';
import 'package:raven/model/publisher.dart';

import '../common.dart';

void main() {
  Publisher publisher = TheVerge();

  test('Extract Categories Test', () async {
    await ExtractorTest.categoriesTest(publisher);
  });

  test('Category Articles Test', () async {
    await ExtractorTest.categoryArticlesTest(publisher);
  });

  test('Search Articles Test', () async {
    await ExtractorTest.searchedArticlesTest(publisher, 'tech');
  });
}
