import 'package:test/test.dart';
import 'package:raven/repository/news/general/national/india/thehindu.dart';
import 'package:raven/model/publisher.dart';

import '../../../common.dart';


void main() {
  Publisher publisher = TheHindu();

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
