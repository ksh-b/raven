import 'package:test/test.dart';
import 'package:raven/extractor/general/national/india/thehindu.dart';
import 'package:raven/model/publisher.dart';

import '../../../common.dart';


void main() {
  Publisher publisher = TheHindu();

  test('Extract Categories Test', () async {
    await ExtractorTest.categoriesTest(publisher);
  });

  test('Category Articles Test', () async {
    await ExtractorTest.categoryArticlesTest(publisher, skipDateCheck: true);
  });

  test('Search Articles Test', () async {
    await ExtractorTest.searchedArticlesTest(publisher, 'world');
  });
}
