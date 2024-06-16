import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/brain/dio_manager.dart';
import 'package:raven/brain/fallback_provider.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/utils/store.dart';
import 'package:raven/utils/time.dart';

class Searx extends Publisher {
  @override
  String get name => "Searx";

  @override
  String get homePage => Store.searxInstance;

  @override
  Future<Map<String, String>> get categories async => {};

  @override
  Category get mainCategory => Category.custom;

  @override
  bool get hasSearchSupport => false;

  @override
  String get iconUrl {
    return "https://searx.space/favicon.png";
  }

  @override
  Future<NewsArticle> article(NewsArticle newsArticle) async {
    newsArticle = await FallbackProvider().get(newsArticle);
    return newsArticle;
  }

  @override
  Future<Set<NewsArticle>> categoryArticles({
    String category = "/",
    int page = 1,
  }) async {
    return {};
  }

  @override
  Future<Set<NewsArticle>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) async {
    Set<NewsArticle> articles = {};
    var response = await dio().get(
      "$homePage/search",
      queryParameters: {
        "q": searchQuery,
        "language": "auto",
        "categories": "news",
        "pageno": "$page"
      },
    );
    if (response.statusCode == 200) {
      Document document = html_parser.parse(response.data);
      List<Element> articleElements =
          document.querySelectorAll(".category-news");
      for (Element articleElement in articleElements) {
        String? title = articleElement.querySelector("h3 a")?.text;
        String? url = articleElement.querySelector("h3 a")?.attributes["href"];
        String? thumbnail =
            articleElement.querySelector("img")?.attributes["src"];
        String? date =
            articleElement.querySelector("date")?.attributes["datetime"];
        int parsedTime = isoToUnix(date ?? "");

        articles.add(
          NewsArticle(
            publisher: name,
            title: title ?? "",
            content: "",
            excerpt: "",
            author: "",
            url: url?.replaceFirst(homePage, "") ?? "",
            thumbnail: thumbnail ?? "",
            publishedAt: parsedTime,
            tags: [],
            category: "",
          ),
        );
      }
    }
    return articles;
  }
}
