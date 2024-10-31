import 'package:hive/hive.dart';
import 'package:raven/model/article.dart';

class SavedArticles {
  static Box get saved {
    return Hive.box("saved");
  }

  static void saveArticle(Article article) {
    saved.put(article.url, article);
  }

  static void deleteArticle(Article article) {
    saved.delete(article.url);
  }

  static List<Article> getSavedArticles(Article article) {
    return saved.values.toList() as List<Article>;
  }

}
