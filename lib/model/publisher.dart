import 'package:whapp/extractor/general/national/india/thequint.dart';
import 'package:whapp/extractor/general/national/india/thewire.dart';
import 'package:whapp/extractor/general/world/aljazeera.dart';
import 'package:whapp/extractor/general/world/bbc.dart';
import 'package:whapp/extractor/general/world/reuters.dart';
import 'package:whapp/extractor/technology/arstechnica.dart';
import 'package:whapp/extractor/technology/bleepingcomputer.dart';
import 'package:whapp/extractor/technology/engadget.dart';
import 'package:whapp/extractor/technology/theverge.dart';
import 'package:whapp/extractor/technology/torrentfreak.dart';
import 'package:whapp/model/article.dart';
import 'package:whapp/utils/string.dart';

Map<String, Publisher> publishers = {
  "Al Jazeera": AlJazeera(),
  "Ars Technica": ArsTechnica(),
  "BBC": BBC(),
  "BleepingComputer": BleepingComputer(),
  "Engadget": Engadget(),
  "Reuters": Reuters(),
  "The Verge": TheVerge(),
  "The Quint": TheQuint(),
  "The Wire": TheWire(),
  "TorrentFreak": TorrentFreak(),
};

abstract class Publisher {
  String get name;

  String get homePage;

  bool get hasSearchSupport => true;

  String get iconUrl => "$homePage/favicon.ico";

  Future<Map<String, String>> get categories;

  String get mainCategory;

  Future<Set<NewsArticle>> articles({String category = "All", int page = 1}) {
    return category.startsWith("#")
        ? searchedArticles(searchQuery: getAsSearchQuery(category), page: page)
        : categoryArticles(category: category, page: page);
  }

  Future<Set<NewsArticle>> categoryArticles({String category = "All", int page = 1});

  Future<Set<NewsArticle>> searchedArticles({required String searchQuery, int page = 1});

  Future<NewsArticle> article(NewsArticle newsArticle);

  Map<String, dynamic> toJson() {
    return {
      'homePage': homePage,
      'iconUrl': iconUrl,
      'categories': categories,
    };
  }

}
