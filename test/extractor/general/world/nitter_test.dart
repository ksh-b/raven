import 'package:flutter_test/flutter_test.dart';
import 'package:whapp/extractor/general/world/nitter.dart';
import 'package:whapp/model/publisher.dart';

import '../../common.dart';

void main() {
  Publisher publisher = Nitter();

  test('Category Articles Test', () async {
    await ExtractorTest.categoryArticlesTest(publisher, category: "Steam");
  });

  test('Search Articles Test', () async {
    await ExtractorTest.searchedArticlesTest(publisher, 'Steam# ');
  });
}
