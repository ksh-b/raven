import 'package:klaws/model/article.dart';

abstract class ArticleProvider {
  int get page;

  bool get isLoading;

  Map<String, int> get tags;

  Set<Article> get articles;

  Set<Article> get filteredArticles;

  List<String> get selectedTags;

  Future<void> refresh([String? query]);

  Future<void> nextPage();

  Future<void> fetchArticles();

  void updateTags(bool selected, String tag);

  void filter();
}
