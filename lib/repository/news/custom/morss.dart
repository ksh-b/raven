import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/model/article.dart';
import 'package:raven/model/category.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/provider/fallback_provider.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/html_helper.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/time.dart';

class Morss extends Publisher {
  @override
  String get name => "morss";

  @override
  String get homePage => "https://morss.it";

  @override
  Future<Map<String, String>> get categories async => {};

  @override
  String get mainCategory => Category.custom.name;

  @override
  bool get hasSearchSupport => false;

  @override
  Future<Article> article(Article newsArticle) async {
    if (newsArticle.content.isEmpty) {
      newsArticle = await FallbackProvider().get(newsArticle);
      if (newsArticle.thumbnail.isEmpty && newsArticle.content.isNotEmpty) {
        Document document = html_parser.parse(newsArticle.content);
        newsArticle.thumbnail =
            document.querySelector("img[src]")?.attributes["src"] ?? "";
      }
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
    category = category.replaceAll("http://", "").replaceAll("https://", "");
    String url;
    if (category.startsWith(homePage)) {
      url = category;
    } else {
      url = "$homePage/:format=json:cors/$category";
    }
    try {
      var response = await dio().get(url);
      if (response.successful) {
        var data = response.data;
        var items = data["items"];
        for (var item in items) {
          var content = item["content"];
          var excerpt = item.containsKey("desc") ? item["desc"] : "";
          if (isHTML(excerpt)) {
            content = "<b>$excerpt</b>$content";
            excerpt = "";
          }
          articles.add(
            Article(
              publisher: name,
              title: item["title"] ?? "",
              content: content,
              excerpt: excerpt,
              author: "",
              url: item["url"],
              tags: [],
              thumbnail: "",
              publishedAt:
                  item.containsKey("time") ? isoToUnix(item["time"]) : -1,
              category: category,
            ),
          );
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
