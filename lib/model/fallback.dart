import 'package:raven/model/article.dart';

abstract class Fallback {
  String get name;

  Future<MapEntry<bool, Article>> fallback(Article article);
}
