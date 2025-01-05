import 'package:hive/hive.dart';
import 'package:raven/model/article.dart';

class SavedArticles {
  static Box get saved {
    return Hive.box("saved");
  }

  static bool contains(Article article) {
    return saved.values.contains(article);
  }

  static void saveArticle(Article article) async {
    if (saved.keys.contains(article.url)) {
      await deleteArticle(article);
    }
    await saved.put(article.url, article);
  }

  static Future<void> deleteArticle(Article article) async {
    return await saved.delete(article.url);
  }

}
