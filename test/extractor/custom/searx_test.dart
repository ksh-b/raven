import 'package:raven/extractor/custom/searx.dart';
import 'package:test/test.dart';
import 'package:raven/model/publisher.dart';

import '../common.dart';

void main() {
  Publisher publisher = Searx();

  test('Search Articles Test', () async {
    await ExtractorTest.searchedArticlesTest(publisher, 'climate');
  });
}
