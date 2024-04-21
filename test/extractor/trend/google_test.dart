import 'package:raven/extractor/trend/google.dart';
import 'package:test/test.dart';

void main() {
  test('Trends test', () async {
    var list = await GoogleTrend().topics;
    expect(list, isNotEmpty);
  });
}