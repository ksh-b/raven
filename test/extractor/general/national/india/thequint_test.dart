import 'package:flutter_test/flutter_test.dart';
import 'package:raven/extractor/general/national/india/thequint.dart';
import 'package:raven/model/publisher.dart';

import '../../../common.dart';

void main() {
  Publisher publisher = TheQuint();

  test('Extract Categories Test', () async {
    await ExtractorTest.categoriesTest(publisher);
  });

  test('Category Articles Test', () async {
    await ExtractorTest.categoryArticlesTest(publisher);
  });

  test('Search Articles Test', () async {
    await ExtractorTest.searchedArticlesTest(publisher, 'politics');
  });
}
