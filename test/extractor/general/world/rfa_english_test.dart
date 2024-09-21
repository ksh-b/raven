import 'package:raven/repository/news/general/world/rfa_english.dart';
import 'package:test/test.dart';
import 'package:raven/model/publisher.dart';

import '../../common.dart';

void main() {
  Publisher publisher = RfaEnglish();

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
