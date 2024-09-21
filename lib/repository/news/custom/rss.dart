import 'package:dart_rss/dart_rss.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/model/article.dart';
import 'package:raven/model/category.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/provider/fallback_provider.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/time.dart';

class RSSFeed extends Publisher {
  @override
  String get name => "RSS Feed";

  @override
  String get homePage => "";

  @override
  Future<Map<String, String>> get categories async => {};

  @override
  String get mainCategory => Category.custom.name;

  @override
  bool get hasSearchSupport => false;

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
  Future<Article> article(Article newsArticle) async {
    newsArticle = await FallbackProvider().get(newsArticle);
    if (newsArticle.thumbnail == _thumbnail(newsArticle.content)) {
      newsArticle.thumbnail = "";
    }
    return newsArticle;
  }

  @override
  Future<Set<Article>> categoryArticles({
    String category = "/",
    int page = 1,
  }) async {
    if (page > 1) return {};
    Set<Article> articles = {};
    try {
      var response = await dio().get(category);

      if (response.successful) {
        WebFeed feed = WebFeed.fromXmlString(response.data);
        RssFeed rssFeed = const RssFeed();
        Rss1Feed rss1Feed = const Rss1Feed();
        AtomFeed atomFeed = const AtomFeed();
        if (feed.rssVersion == RssVersion.rss2) {
          rssFeed = RssFeed.parse(response.data);
          for (var item in rssFeed.items) {
            var images = item.content?.images.toList() ?? [];
            articles.add(
              Article(
                publisher: name,
                title: item.title ?? "",
                content: item.description ?? "",
                excerpt: "",
                author: item.author ?? "",
                url: item.link?.trim() ?? "",
                tags: item.categories.map((e) => e.value ?? "").toList(),
                thumbnail: images.isNotEmpty
                    ? images.first
                    : _thumbnail(item.description ?? ""),
                publishedAt:
                    item.pubDate != null ? stringToUnix(item.pubDate!) : -1,
                category: category,
              ),
            );
          }
        } else if (feed.rssVersion == RssVersion.atom) {
          atomFeed = AtomFeed.parse(response.data);
          for (var item in atomFeed.items) {
            var images = item.media?.thumbnails.toList() ?? [];
            articles.add(
              Article(
                publisher: name,
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
                category: category,
              ),
            );
          }
        } else if (feed.rssVersion == RssVersion.rss1) {
          rss1Feed = Rss1Feed.parse(response.data);
          for (var item in rss1Feed.items) {
            var images = item.content?.images.toList() ?? [];
            articles.add(
              Article(
                publisher: name,
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
                category: category,
              ),
            );
          }
        } else {
          for (var item in feed.items) {
            articles.add(
              Article(
                publisher: name,
                title: item.title,
                content: item.body,
                excerpt: "",
                author: "",
                url: item.links.isNotEmpty
                    ? (item.links.first?.trim() ?? "")
                    : "",
                tags: [],
                thumbnail: _thumbnail(item.body),
                publishedAt: item.updated?.millisecondsSinceEpoch ?? -1,
                category: category,
              ),
            );
          }
        }
      }
    } catch (e) {
      return articles;
    }
    return articles;
  }

  @override
  Future<Set<Article>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) async {
    return {};
  }

  @override
  bool get hasCustomSupport => true;
}
