import 'package:flutter_test/flutter_test.dart';
import 'package:whapp/extractor/technology/engadget.dart';
import 'package:whapp/model/publisher.dart';

import '../common.dart';

void main() {
  Publisher publisher = Engadget();

  test('Extract Categories Test', () async {
    await ExtractorTest.categoriesTest(publisher);
  });

  test('Category Articles Test', () async {
    await ExtractorTest.categoryArticlesTest(publisher, category: "/news");
  });

  test('Search Articles Test', () async {
    await ExtractorTest.searchedArticlesTest(publisher, 'tech');
  });
}
