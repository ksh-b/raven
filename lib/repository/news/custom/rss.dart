import 'package:dart_rss/dart_rss.dart';
import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:klaws/model/article.dart';
import 'package:klaws/model/publisher.dart';
import 'package:raven/provider/fallback_provider.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/time.dart';

part 'rss.g.dart';

@HiveType(typeId: 30)
class RSSFeed extends Source {
  RSSFeed({
    required super.id,
    required super.name,
    required super.homePage,
    required super.hasSearchSupport,
    required super.hasCustomSupport,
    required super.iconUrl,
    required super.siteCategories,
  });

  @override
  String get iconUrl {
    return "https://www.rssboard.org/images/rss-feed-icon-96-by-96.png";
  }

  String _thumbnail(String content) {
    if (content.isEmpty) return "";
    Document document = html_parser.parse(content);
    return document.querySelector("img[src]")?.attributes["src"] ?? "";
  }

  @override
  Future<Article> article(Article article, Dio dio) async {
    article = await FallbackProvider().get(article);
    // remove thumbnail if content has it already
    if (article.thumbnail == _thumbnail(article.content)) {
      article.thumbnail = "";
    }
    return article;
  }

  @override
  Future<Set<Article>> categoryArticles({
    String category = "",
    int page = 1,
    required Dio dio
  }) async {
    if (page > 1) return {};
    Set<Article> articles = {};
    try {
      var response = await dio.get(category);
      if (response.successful) {
        WebFeed feed = WebFeed.fromXmlString(response.data);
        if (feed.rssVersion == RssVersion.rss2) {
          articles = getRss2Articles(response, category);
        } else if (feed.rssVersion == RssVersion.atom) {
          articles = getAtomArticles(response, category);
        } else if (feed.rssVersion == RssVersion.rss1) {
          articles = getRss1Articles(response, category);
        } else {
          articles = getFeedArticles(feed, category);
        }
      }
    } catch (e) {
      return articles;
    }
    return articles;
  }

  Set<Article> getFeedArticles(WebFeed feed, String category) {
    Set<Article> articles = {};
    for (var item in feed.items) {
      articles.add(
        Article(
          source: this,
          sourceName: name,
          title: item.title,
          content: item.body,
          excerpt: "",
          author: "",
          url: item.links.isNotEmpty ? (item.links.first?.trim() ?? "") : "",
          tags: [],
          thumbnail: _thumbnail(item.body),
          publishedAt: item.updated?.millisecondsSinceEpoch ?? -1,
          publishedAtString: item.updated?.toIso8601String() ?? "",
          category: category,
        ),
      );
    }
    return articles;
  }

  Set<Article> getRss1Articles(Response<dynamic> response, String category) {
    Set<Article> articles = {};
    var rss1Feed = Rss1Feed.parse(response.data);
    for (var item in rss1Feed.items) {
      var images = item.content?.images.toList() ?? [];
      articles.add(
        Article(
          source: this,
          sourceName: name,
          title: item.title ?? "",
          content: item.description ?? "",
          excerpt: "",
          author: item.dc?.contributor ?? "",
          url: item.link?.trim() ?? "",
          tags: item.dc?.subjects ?? [],
          thumbnail: images.isNotEmpty
              ? images.first
              : _thumbnail(item.description ?? ""),
          publishedAt:
              item.dc?.date != null ? stringToUnix(item.dc!.date!) : -1,
          publishedAtString: item.dc?.date ?? "",
          category: category,
        ),
      );
    }
    return articles;
  }

  Set<Article> getAtomArticles(Response<dynamic> response, String category) {
    Set<Article> articles = {};
    var atomFeed = AtomFeed.parse(response.data);
    for (var item in atomFeed.items) {
      var images = item.media?.thumbnails.toList() ?? [];
      articles.add(
        Article(
          source: this,
          sourceName: name,
          title: item.title ?? "",
          content: item.content ?? "",
          excerpt: item.summary ?? "",
          author: item.authors.join(", "),
          url: item.links.first.href?.trim() ?? "",
          tags: item.categories.map((e) => e.label ?? "").toList(),
          thumbnail: images.isNotEmpty
              ? images.first.url ?? ""
              : _thumbnail(item.content ?? ""),
          publishedAt:
              item.published != null ? stringToUnix(item.published!) : -1,
          publishedAtString: item.published ?? "",
          category: category,
        ),
      );
    }
    return articles;
  }

  Set<Article> getRss2Articles(Response<dynamic> response, String category) {
    Set<Article> articles = {};
    var rssFeed = RssFeed.parse(response.data);
    for (var item in rssFeed.items) {
      var images = item.media?.thumbnails.map((e) => e.url ?? "").toList() ??
          item.content?.images.toList() ??
          [];
      articles.add(
        Article(
          source: this,
          sourceName: name,
          title: item.title ?? "",
          content: item.description ?? "",
          excerpt: "",
          author: item.author ?? "",
          url: item.link?.trim() ?? "",
          tags: item.categories.map((e) => e.value ?? "").toList(),
          thumbnail: images.isNotEmpty
              ? images.first
              : _thumbnail(item.description ?? ""),
          publishedAt: item.pubDate != null
              ? stringToUnix(item.pubDate!, format: "RFC-1123")
              : -1,
          publishedAtString: item.pubDate ?? "",
          category: category,
        ),
      );
    }
    return articles;
  }

  @override
  Future<Set<Article>> searchedArticles({
    required String searchQuery,
    int page = 1,
    required Dio dio
  }) async {
    return {};
  }

  @override
  bool get hasCustomSupport => true;
}
