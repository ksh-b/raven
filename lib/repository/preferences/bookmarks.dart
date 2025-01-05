import 'package:hive/hive.dart';
import 'package:raven/model/article.dart';

class BookmarkedArticles {
  static Box get bookmarks {
    return Hive.box("bookmarks");
  }

  static bool contains(Article article)  {
    return bookmarks.keys.contains(article.url);
  }

  static void saveArticle(Article article) async {
    if (bookmarks.keys.contains(article.url)) {
      return;
    }
    await bookmarks.put(article.url, article);
  }

  static Future<void> deleteArticle(Article article) async {
    return await bookmarks.delete(article.url);
  }

}
