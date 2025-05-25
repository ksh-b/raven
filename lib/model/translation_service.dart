import 'package:klaws/model/article.dart';

abstract class TranslationService {
  Map<String, dynamic> languages();
  Future<Article> translateArticle(Article article);
  Future<String> translate(String text);
}
