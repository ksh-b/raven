import 'package:flutter/material.dart';
import 'package:klaws/model/article.dart';
import 'package:klaws/model/publisher.dart';
import 'package:raven/repository/preferences/subscriptions.dart';
import 'package:raven/utils/string.dart';

import 'article.dart';

class SearchArticleProvider extends ChangeNotifier implements ArticleProvider {
  int _page = 1;
  bool _lock = false;
  Map<String, int> _tags = {};
  @override
  List<String> selectedTags = [];

  @override
  int get page => _page;

  @override
  Map<String, int> get tags => _tags;

  @override
  bool get isLoading => _lock;
  Set<Article> _articles = {};
  Set<Article> _filteredArticles = {};

  @override
  Set<Article> get filteredArticles => _filteredArticles;
  String _searchQuery = "";

  @override
  Future<void> refresh([String? query]) async {
    _page = 1;
    _articles = {};
    _tags = {};
    selectedTags = [];
    _searchQuery = query??"";
    fetchSearchedArticles();
  }

  @override
  Set<Article> get articles =>
      _filteredArticles.isNotEmpty ? _filteredArticles : _articles;

  @override
  Future<void> nextPage() async {
    _page = _page + 1;
    fetchSearchedArticles();
  }

  Future<void> fetchSearchedArticles() async {
    _lock = true;
    notifyListeners();
    Set<Article> articles = {};
    Set<Source> publishers = UserSubscriptionPref.selectedSubscriptions
        .where((e) {
          return e.source.hasSearchSupport;
        })
        .map((e) => e.source)
        .toList()
        .toSet();
    for (Source publisher in publishers) {
      _tags.putIfAbsent(publisher.toString().toCapitalized, () => 1); // fixme
      _tags.putIfAbsent(publisher.name, () => 3);
      var searchedArticles = await publisher
          .searchedArticles(searchQuery: _searchQuery, page: page);
      articles.addAll(searchedArticles);
      for (var cArticle in searchedArticles) {
        for (var tag in cArticle.tags) {
          _tags.putIfAbsent(tag, () => 0);
        }
      }
    }

    List<MapEntry<String, int>> entries = _tags.entries.toList();
    entries.sort((e1, e2) => _tags[e2.key]!.compareTo(_tags[e1.key]!));
    _tags = Map.fromEntries(entries);

    articles = (articles.toList()
          ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt)))
        .toSet();
    _articles.addAll(articles);
    _lock = false;
    filter();
    notifyListeners();
  }

  @override
  void updateTags(bool selected, String tag) {
    if (selected) {
      selectedTags = selectedTags..add(tag);
    } else {
      selectedTags = selectedTags..remove(tag);
    }

    filter();

    notifyListeners();
  }

  @override
  void filter() {
    if (selectedTags.isEmpty) {
      _filteredArticles = _articles;
    } else {
      _filteredArticles = _articles.where((element) {
        return selectedTags.contains(element.source.id) ||
            selectedTags.contains(element.category) ||
            selectedTags.contains(element.source
                .siteCategories.toString() // fixme
                .toLowerCase()) ||
            element.tags.any((element) => selectedTags.contains(element));
      }).toSet();
    }

    notifyListeners();
  }

  @override
  Future<void> fetchArticles() {
    // TODO: implement fetchArticles
    throw UnimplementedError();
  }
}
