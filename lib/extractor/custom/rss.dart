import 'package:dart_rss/dart_rss.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:raven/api/smort.dart';
import 'package:raven/brain/html_content_extractor.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/utils/time.dart';

class RSSFeed extends Publisher {
  @override
  String get name => "RSS Feed";

  @override
  String get homePage => "";

  @override
  Future<Map<String, String>> get categories async => {};

  @override
  Category get mainCategory => Category.custom;

  @override
  bool get hasSearchSupport => false;

  @override
  String get iconUrl => "https://www.rssboard.org/favicon.ico";

  @override
  Future<NewsArticle> article(NewsArticle newsArticle) async {
    if (newsArticle.content.isEmpty) {
      newsArticle = await HtmlContentExtractor().fallback(newsArticle);
      if (newsArticle.content.isEmpty) {
        newsArticle = await Smort().fallback(newsArticle);
      }
      if (newsArticle.thumbnail.isEmpty && newsArticle.content.isNotEmpty) {
        Document document = html_parser.parse(newsArticle.content);
        newsArticle.thumbnail =
            document.querySelector("img[src]")?.attributes["src"] ?? "";
      }
    }
    return newsArticle;
  }

  @override
  Future<Set<NewsArticle>> categoryArticles({
    String category = "/",
    int page = 1,
  }) async {
    if (page > 1) return {};
    Set<NewsArticle> articles = {};
    final response = await http.get(Uri.parse(category));
    if (response.statusCode == 200) {
      WebFeed feed = WebFeed.fromXmlString(response.body);
      RssFeed rssFeed = RssFeed();
      Rss1Feed rss1Feed = Rss1Feed();
      AtomFeed atomFeed = AtomFeed();
      if (feed.rssVersion == RssVersion.rss2) {
        rssFeed = RssFeed.parse(response.body);
        for (var item in rssFeed.items) {
          articles.add(
            NewsArticle(
              publisher: name,
              title: item.title ?? "",
              content: item.content?.value ?? "",
              excerpt: item.description ?? "",
              author: item.author ?? "",
              url: item.link ?? "",
              tags: item.categories.map((e) => e.value ?? "").toList(),
              thumbnail: item.content?.images.first ?? "",
              publishedAt:
                  item.pubDate != null ? stringToUnix(item.pubDate!) : -1,
              category: category,
            ),
          );
        }
      } else if (feed.rssVersion == RssVersion.atom) {
        atomFeed = AtomFeed.parse(response.body);
        for (var item in atomFeed.items) {
          articles.add(
            NewsArticle(
              publisher: name,
              title: item.title ?? "",
              content: item.content ?? "",
              excerpt: item.summary ?? "",
              author: item.authors.join(", "),
              url: item.links.first.href ?? "",
              tags: item.categories.map((e) => e.label ?? "").toList(),
              thumbnail: item.media?.thumbnails.first.url ?? "",
              publishedAt:
                  item.published != null ? stringToUnix(item.published!) : -1,
              category: category,
            ),
          );
        }
      } else if (feed.rssVersion == RssVersion.rss1) {
        rss1Feed = Rss1Feed.parse(response.body);
        for (var item in rss1Feed.items) {
          articles.add(
            NewsArticle(
              publisher: name,
              title: item.title ?? "",
              content: item.content?.value ?? "",
              excerpt: item.description ?? "",
              author: item.dc?.contributor ?? "",
              url: item.link ?? "",
              tags: item.dc?.subjects ?? [],
              thumbnail: item.content?.images.first ?? "",
              publishedAt:
                  item.dc?.date != null ? stringToUnix(item.dc!.date!) : -1,
              category: category,
            ),
          );
        }
      } else {
        for (var item in feed.items) {
          articles.add(
            NewsArticle(
              publisher: name,
              title: item.title,
              content: item.body,
              excerpt: "",
              author: "",
              url: item.links.first ?? "",
              tags: [],
              thumbnail: "",
              publishedAt: item.updated?.millisecondsSinceEpoch ?? -1,
              category: category,
            ),
          );
        }
      }
    }
    return articles;
  }

  @override
  Future<Set<NewsArticle>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) async {
    return {};
  }
}
