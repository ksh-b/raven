import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/model/article.dart';
import 'package:raven/model/category.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/time.dart';

class ArsTechnica extends Publisher {
  @override
  String get homePage => "https://arstechnica.com";

  @override
  String get name => "Ars Technica";

  @override
  String get mainCategory => Category.technology.name;

  @override
  Future<Article> article(Article newsArticle) async {
    var response = await dio().get("$homePage${newsArticle.url}");
    if (response.successful) {
      Document document = html_parser.parse(response.data);
      String? thumbnail =
          document.querySelector(".figure img")?.attributes["href"];
      String? content = document
          .querySelectorAll(".article-content p")
          .map((e) => e.innerHtml)
          .join("<br><br>");
      newsArticle = newsArticle.fill(content: content, thumbnail: thumbnail);
    }
    return newsArticle;
  }

  @override
  Future<Map<String, String>> get categories async => {
        "IT": "/information-technology",
        "Tech": "/gadgets",
        "Science": "/science",
        "Policy": "/tech-policy",
        "Cars": "/cars",
        "Gaming": "/gaming"
      };

  @override
  bool get hasSearchSupport => false;

  @override
  Future<Set<Article>> categoryArticles({
    String category = "",
    int page = 1,
  }) async {
    Set<Article> articles = {};
    var tag = category == "/" ? "" : category;
    var response = await dio().get("$homePage$category/page/$page");

    if (response.successful) {
      Document document = html_parser.parse(response.data);
      List<Element> articleElements = document.querySelectorAll(".article");
      for (Element articleElement in articleElements) {
        String? title = articleElement.querySelector("h2 a")?.text;
        String? excerpt = articleElement.querySelector(".excerpt")?.text;
        String? author =
            articleElement.querySelector("span[itemprop=name]")?.text;
        String? date =
            articleElement.querySelector("time")?.attributes["datetime"] ?? "";
        String? url = articleElement.querySelector("h2 a")?.attributes["href"];
        String? thumbnail =
            articleElement.querySelector("figure div")?.attributes["style"];

        articles.add(
          Article(
            publisher: name,
            title: title ?? "",
            content: "",
            excerpt: excerpt ?? "",
            author: author ?? "",
            url: url?.replaceFirst(homePage, "") ?? "",
            thumbnail: extractUrl(thumbnail)
                .replaceFirst("-360x200", "")
                .replaceFirst("-150x150", ""),
            publishedAt: stringToUnix(date),
            tags: [tag],
            category: category,
          ),
        );
      }
    }
    return articles;
  }

  String extractUrl(String? inputString) {
    RegExp regExp = RegExp(r"url\('([^']*)'\)");
    if (inputString != null) {
      Match? match = regExp.firstMatch(inputString);
      if (match != null) {
        return match.group(1)!;
      } else {
        return "";
      }
    }
    return "";
  }

  @override
  Future<Set<Article>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) async {
    return {};
  }
}
