import 'package:test/test.dart';
import 'package:raven/extractor/technology/bleepingcomputer.dart';
import 'package:raven/model/publisher.dart';

import '../common.dart';

void main() {
  Publisher publisher = BleepingComputer();

  test('Extract Categories Test', () async {});

  test('Category Articles Test', () async {
    await ExtractorTest.categoryArticlesTest(publisher, category: '', ignoreDateCheck: true);
  });

  test('Search Articles Test', () async {
    await ExtractorTest.searchedArticlesTest(publisher, 'tech');
  });
}
