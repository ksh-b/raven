import 'package:raven/model/trends.dart';

class BraveTrend extends Trend {
  @override
  String get url => "https://search.brave.com/search?q=news";

  @override
  String get locator => "#news-topics a";
}
