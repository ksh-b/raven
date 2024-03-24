import 'package:raven/model/trends.dart';

class YahooTrend extends Trend {

  @override
  String get url => "https://www.yahoo.com/";

  @override
  String get locator => ".trendingNowTextList a span:last-child";

}