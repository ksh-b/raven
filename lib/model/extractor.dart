import 'package:klaws/model/article.dart';
import 'package:raven/utils/string.dart';

abstract class Extractor {
  Future<Set<Article>> articles({String category = "All", int page = 1}) {
    return category.startsWith("#")
        ? searchedArticles(searchQuery: getAsSearchQuery(category), page: page)
        : categoryArticles(category: category, page: page);
  }

  Future<Set<Article>> categoryArticles(
      {String category = "All", int page = 1});

  Future<Set<Article>> searchedArticles(
      {required String searchQuery, int page = 1});

  Future<Article> article(Article newsArticle);
}
