import 'package:raven/extractor/general/national/bangladesh/prothamalo.dart';
import 'package:test/test.dart';
import 'package:raven/model/publisher.dart';

import '../../../common.dart';


void main() {
  Publisher publisher = ProthamAlo();

  test('Extract Categories Test', () async {
    await ExtractorTest.categoriesTest(publisher);
  });

  test('Category Articles Test', () async {
    await ExtractorTest.categoryArticlesTest(publisher);
  });

  test('Search Articles Test', () async {
    await ExtractorTest.searchedArticlesTest(publisher, 'ওয়ার্ল্ড');
  });
}
