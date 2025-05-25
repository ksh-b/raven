import 'package:raven/model/trend.dart';
import 'package:raven/repository/trend/google.dart';
import 'package:raven/repository/trend/none.dart';
import 'package:raven/repository/trend/yahoo.dart';

Map<String, Trend> trends = {
  for (var trends in [
    NoneTrend(),
    GoogleTrend(),
    YahooTrend(),
  ])
    trends.name: trends,
};
