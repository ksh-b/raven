import 'package:whapp/extractor/general/national/india/thewire.dart';
import 'package:whapp/extractor/general/world/aljazeera.dart';
import 'package:whapp/extractor/general/world/bbc.dart';
import 'package:whapp/extractor/general/world/reuters.dart';
import 'package:whapp/extractor/technology/theverge.dart';
import 'package:whapp/extractor/technology/torrentfreak.dart';
import 'package:whapp/model/article.dart';
import 'package:whapp/utils/string.dart';



Map<String, Publisher> publishers = {
  "Al Jazeera": AlJazeera(),
  "BBC": BBC(),
  "Reuters": Reuters(),
  "The Verge": TheVerge(),
  "The Wire": TheWire(),
  "TorrentFreak": TorrentFreak(),
};

abstract class Publisher {
  String get name;

  String get homePage;

  bool get hasSearchSupport => true;

  String get iconUrl => "$homePage/favicon.ico";

  Future<Map<String, String>> get categories;


  Future<Set<NewsArticle?>> articles({String category = "All", int page = 1}) {
    return category.startsWith("#")
        ? searchedArticles(searchQuery: getAsSearchQuery(category), page: page)
        : categoryArticles(category: category, page: page);
  }

  Future<Set<NewsArticle?>> categoryArticles({String category = "All", int page = 1});

  Future<Set<NewsArticle?>> searchedArticles({required String searchQuery, int page = 1});

  Future<NewsArticle?> article(String url);

  Map<String, dynamic> toJson() {
    return {
      'homePage': homePage,
      'iconUrl': iconUrl,
      'categories': categories,
    };
  }

}
