import 'package:klaws/model/article.dart';

abstract class Fallback {
  String get name;

  Future<MapEntry<bool, Article>> fallback(Article article);
}
