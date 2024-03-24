import 'package:raven/model/trends.dart';

class APNewsTrend extends Trend {

  @override
  String get url => "https://apnews.com/";

  @override
  String get locator => ".PageListTrending .PagePromoContentIcons-text";

}