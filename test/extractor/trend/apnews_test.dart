import 'package:raven/extractor/trend/apnews.dart';
import 'package:test/test.dart';

void main() {
  test('Trends test', () async {
    var list = await APNewsTrend().topics;
    expect(list, isNotEmpty);
  });
}