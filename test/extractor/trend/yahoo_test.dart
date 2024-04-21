import 'package:raven/extractor/trend/yahoo.dart';
import 'package:test/test.dart';

void main() {
  test('Trends test', () async {
    var list = await YahooTrend().topics;
    expect(list, isNotEmpty);
  });
}