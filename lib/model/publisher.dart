import 'package:raven/model/article.dart';

import '../repository/publishers.dart';
import '../utils/string.dart';

abstract class Publisher {
  String get name;

  String get homePage;

  bool get hasSearchSupport;

  bool get hasCustomSupport => true;

  String get iconUrl => "$homePage/favicon.ico";

  Future<Map<String, String>> get categories;

  String get mainCategory;

  Publisher();

  factory Publisher.fromString(String publisherName) {
    if (publishers.containsKey(publisherName)) {
      return publishers[publisherName]!;
    }
    throw Exception("Invalid publisher name");
  }

  Future<Article> article(Article newsArticle) {
    throw UnimplementedError();
  }

  Future<Set<Article>> articles({required String category, int page = 1}) {
    return category.startsWith("#")
        ? searchedArticles(searchQuery: getAsSearchQuery(category), page: page)
        : categoryArticles(category: category, page: page);
  }

  Future<Set<Article>> categoryArticles({
    required String category,
    int page = 1,
  });

  Future<Set<Article>> searchedArticles({
    required String searchQuery,
    int page = 1,
  });
}
