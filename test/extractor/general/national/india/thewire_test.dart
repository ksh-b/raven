import 'package:flutter_test/flutter_test.dart';
import 'package:whapp/extractor/general/national/india/thewire.dart';
import 'package:whapp/model/publisher.dart';

import '../../../common.dart';

void main() {
  Publisher publisher = TheWire();
  
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

