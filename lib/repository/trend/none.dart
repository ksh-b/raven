import 'package:raven/model/trend.dart';

class NoneTrend extends Trend {
  @override
  String get name => "None";

  @override
  String get url => "";

  @override
  String get locator => "";

  @override
  Future<List<String>> get topics async => [];

  @override
  List<String> get locations => [];
}
