import 'package:raven/extractor/custom/morss.dart';
import 'package:raven/extractor/custom/rss.dart';
import 'package:raven/extractor/general/national/bangladesh/prothamalo.dart';
import 'package:raven/extractor/general/national/bangladesh/prothamalo_en.dart';
import 'package:raven/extractor/general/national/india/thehindu.dart';
import 'package:raven/extractor/general/national/india/theindianexpress.dart';
import 'package:raven/extractor/general/national/india/thequint.dart';
import 'package:raven/extractor/general/national/india/thewire.dart';
import 'package:raven/extractor/general/world/aljazeera.dart';
import 'package:raven/extractor/general/world/apnews.dart';
import 'package:raven/extractor/general/world/bbc.dart';
import 'package:raven/extractor/general/world/cnn.dart';
import 'package:raven/extractor/general/world/reuters.dart';
import 'package:raven/extractor/general/world/theguardian.dart';
import 'package:raven/extractor/technology/androidpolice.dart';
import 'package:raven/extractor/technology/arstechnica.dart';
import 'package:raven/extractor/technology/bleepingcomputer.dart';
import 'package:raven/extractor/technology/engadget.dart';
import 'package:raven/extractor/technology/theverge.dart';
import 'package:raven/extractor/technology/torrentfreak.dart';
import 'package:raven/extractor/technology/xdadevelopers.dart';
import 'package:raven/model/article.dart';
import 'package:raven/utils/string.dart';

Map<String, Publisher> publishers = {
  "Al Jazeera": AlJazeera(),
  "Android Police": AndroidPolice(),
  "AP News": APNews(),
  "Ars Technica": ArsTechnica(),
  "BBC": BBC(),
  "BleepingComputer": BleepingComputer(),
  "CNN": CNN(),
  "Engadget": Engadget(),
  "morss": Morss(),
  "Protham Alo": ProthamAloEn(),
  "Reuters": Reuters(),
  "RSS Feed": RSSFeed(),
  "The Guardian": TheGuardian(),
  "The Hindu": TheHindu(),
  "The Indian Express": TheIndianExpress(),
  "The Verge": TheVerge(),
  "The Quint": TheQuint(),
  "The Wire": TheWire(),
  "TorrentFreak": TorrentFreak(),
  "XDA Developers": XDAdevelopers(),
  "প্রথম আলো": ProthamAlo(),
};

enum Category {
  world,
  technology,
  india,
  custom,
}

abstract class Publisher {
  String get name;

  String get homePage;

  bool get hasSearchSupport => true;

  String get iconUrl => "$homePage/favicon.ico";

  Future<Map<String, String>> get categories;

  Category get mainCategory;

  Future<Set<NewsArticle>> articles({String category = "All", int page = 1}) {
    return category.startsWith("#")
        ? searchedArticles(searchQuery: getAsSearchQuery(category), page: page)
        : categoryArticles(category: category, page: page);
  }

  Future<Set<NewsArticle>> categoryArticles(
      {String category = "All", int page = 1});

  Future<Set<NewsArticle>> searchedArticles(
      {required String searchQuery, int page = 1});

  Future<NewsArticle> article(NewsArticle newsArticle);

  Map<String, dynamic> toJson() {
    return {
      'homePage': homePage,
      'iconUrl': iconUrl,
    };
  }
}
