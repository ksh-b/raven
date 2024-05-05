import 'package:dart_rss/dart_rss.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:raven/api/smort.dart';
import 'package:raven/brain/html_content_extractor.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';

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
