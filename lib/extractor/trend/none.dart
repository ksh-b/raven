import 'package:whapp/model/trends.dart';

class NoneTrend extends Trend {

  @override
  String get url => "";

  @override
  String get locator => "";

  @override
  Future<List<String>> get topics async => [];
}