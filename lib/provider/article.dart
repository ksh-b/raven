import 'package:flutter/material.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/repository/preferences/content.dart';
import 'package:raven/repository/preferences/subscriptions.dart';
import 'package:raven/utils/string.dart';

class ArticleProvider extends ChangeNotifier {
  int _page = 1;
  bool _lock = false;
  Map<String, int> _tags = {};
  List<String> selectedTags = [];

  int get page => _page;

  Map<String, int> get tags => _tags;

  bool get isLoading => _lock;

  Set<Article> _articles = {};
  Set<Article> _filteredArticles = {};

  Set<Article> get filteredArticles => _filteredArticles;

  Future<void> refresh() async {
    _page = 1;
    _articles = {};
    _tags = {};
    selectedTags = [];
    fetchArticles();
  }

  Set<Article> get articles =>
      _filteredArticles.isNotEmpty ? _filteredArticles : _articles;

  Future<void> nextPage() async {
    _page = _page + 1;
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    _lock = true;
    notifyListeners();
    Set<Article> articles = {};
    Set<Source> publishers = UserSubscriptionPref.selectedSubscriptions
        .map((e) => e.source)
        .toList()
        .toSet();
    for (Source publisher in publishers) {
      List<String> categories =
          UserSubscriptionPref.selectedSubscriptions.where((subscription) {
        return subscription.source == publisher;
      }).map((subscription) {
        return subscription.categoryPath;
      }).toList();
      // for (var cat in publisher.siteCategories) {
      //   tags.putIfAbsent(cat.toCapitalized, () => 1);
      // }
      tags.putIfAbsent(publisher.name, () => 3);

      for (String category in categories) {
        Set<Article> categoryArticles = {};
        try {
          categoryArticles = await publisher
              .categoryArticles(category: category, page: _page);
        } catch (e) {
          continue;
        }
        articles.addAll(categoryArticles);
        var categories =
            categoryArticles.map((e) => e.category).toSet().toList();
        for (var category in categories) {
          tags.putIfAbsent(category, () => 2);
        }
        for (var cArticle in categoryArticles) {
          for (var tag in cArticle.tags) {
            tags.putIfAbsent(tag, () => 0);
          }
        }
      }
    }

    List<MapEntry<String, int>> sortedTags = tags.entries.where((it) => it.key.isNotEmpty).toList();
    sortedTags.sort((e1, e2) => tags[e2.key]!.compareTo(tags[e1.key]!));
    _tags = Map.fromEntries(sortedTags);

    articles = (articles.toList()
          ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt)))
        .toSet();

    if(ContentPref.shouldFilterContent) {
      String keyword_ = "";
      articles.map((article) {
        var shouldHide = ContentPref.filters.where((filter) {
          return filter.publisher == article.source.id ||
              filter.publisher == "any";
        }).where((filter) {
          var keyword = RegExp(filter.keyword.toLowerCase());
          var fieldsToSearch = [
            if (filter.inTitle) article.title,
            if (filter.inContent) article.content,
            if (filter.inAuthor) article.author,
            if (filter.inUrl) article.url,
            if (filter.inTags) article.tags.join(' '),
          ];

          if (filter.inAny) {
            fieldsToSearch = [
              article.title,
              article.content,
              article.author,
              article.url,
              article.tags.join(' ')
            ];
          }
          keyword_ = keyword.pattern;
          return fieldsToSearch
              .any((field) => field.toLowerCase().contains(keyword));
        }).isNotEmpty;
        if (shouldHide) {
          article.metadata.putIfAbsent(Metadata.filtered.name, () => keyword_,);
        }
        return article;
      }).toList();

    }

    _articles.addAll(articles);
    _lock = false;
    filter();
    notifyListeners();
  }

  void updateTags(bool selected, String tag) {
    if (selected) {
      selectedTags = selectedTags..add(tag);
    } else {
      selectedTags = selectedTags..remove(tag);
    }

    filter();

    notifyListeners();
  }

  void filter() {
    if (selectedTags.isEmpty) {
      _filteredArticles = _articles;
    } else {
      _filteredArticles = _articles.where((element) {
        return selectedTags.contains(element.source.id) ||
            selectedTags.contains(element.category) ||
            selectedTags.contains(element.source
                .siteCategories.toString() // FIXME
                .toLowerCase()) ||
            element.tags.any((element) => selectedTags.contains(element));
      }).toSet();
    }

    notifyListeners();
  }
}
