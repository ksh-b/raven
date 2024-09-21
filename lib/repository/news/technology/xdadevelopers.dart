import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/model/article.dart';
import 'package:raven/model/category.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/time.dart';

class XDAdevelopers extends Publisher {
  @override
  String get homePage => "https://www.xda-developers.com";

  @override
  String get name => "XDA Developers";

  @override
  String get mainCategory => Category.technology.name;

  @override
  String get iconUrl =>
      "https://www.xda-developers.com/public/build/images/favicon-48x48.8f822f21.png";

  @override
  Future<Article> article(Article newsArticle) async {
    var response = await dio().get("$homePage${newsArticle.url}");
    if (response.successful) {
      Document document = html_parser.parse(response.data);
      String? content = document.querySelector(".article-body")?.innerHtml;
      List<String> related = document
          .querySelectorAll(".no-badge.small")
          .map((e) => e.innerHtml)
          .toList();
      for (String rel in related) {
        content = content?.replaceFirst(rel, "");
      }
      newsArticle = newsArticle.fill(
        content: content,
      );
    }
    return newsArticle;
  }

  @override
  bool get hasSearchSupport => false;

  @override
  Future<Map<String, String>> get categories async {
    Map<String, String> map = {};
    var response = await dio().get(homePage);

    if (response.successful) {
      var document = html_parser.parse(response.data);
      document.querySelectorAll(".sidenav-link[href]").forEach((element) {
        map.putIfAbsent(
          element.text.trim(),
          () => element.attributes["href"]!.replaceAll(homePage, ""),
        );
      });
    }

    var unsupported = ["Sign in", "Newsletter"];
    return map..removeWhere((key, value) => unsupported.contains(key));
  }

  @override
  Future<Set<Article>> categoryArticles({
    String category = "",
    int page = 1,
  }) async {
    Set<Article> articles = {};
    var response = await dio().get("$homePage/$category/$page");
    if (response.successful) {
      Document document = html_parser.parse(response.data);
      List<Element> articleElements =
          document.querySelectorAll(".listing-content .article");
      for (Element articleElement in articleElements) {
        String? title =
            articleElement.querySelector(".display-card-title")?.text;
        String? excerpt =
            articleElement.querySelector(".display-card-excerpt")?.text;
        String? author =
            articleElement.querySelector(".display-card-author")?.text;
        String? url = articleElement
            .querySelector(".display-card-title a")
            ?.attributes["href"];
        var tags = articleElement
            .querySelectorAll(".listing-title")
            .map((e) => e.text)
            .toList();
        String? thumbnail =
            articleElement.querySelector("picture img")?.attributes["src"];
        String? content =
            articleElement.querySelector(".display-card-firstParagraph")?.text;
        String? date = articleElement.querySelector(".display-card-date")?.attributes['datetime'];
        int parsedTime = isoToUnix(date ?? "");

        articles.add(
          Article(
            publisher: name,
            title: title?.trim() ?? "",
            content: content ?? "",
            excerpt: excerpt ?? "",
            author: author ?? "",
            url: url?.replaceFirst(homePage, "") ?? "",
            thumbnail: thumbnail ?? "",
            publishedAt: parsedTime,
            tags: tags,
            category: category,
          ),
        );
      }
    }

    return articles;
  }

  @override
  Future<Set<Article>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) async {
    Set<Article> articles = {};
    var response = await dio().get("$homePage/search/?q=$searchQuery");
    if (response.successful) {
      Document document = html_parser.parse(response.data);
      List<Element> articleElements =
          document.querySelectorAll(".listing-content .article");
      for (Element articleElement in articleElements) {
        String? title =
            articleElement.querySelector(".display-card-title")?.text;
        String? excerpt =
            articleElement.querySelector(".display-card-excerpt")?.text;
        String? author =
            articleElement.querySelector(".display-card-author")?.text;
        String? url = articleElement
            .querySelector(".display-card-title a")
            ?.attributes["href"];
        var tags = articleElement
            .querySelectorAll(".listing-title")
            .map((e) => e.text)
            .toList();
        String? thumbnail =
            articleElement.querySelector("picture img")?.attributes["src"];
        String? date = articleElement.querySelector(".display-card-date")?.attributes['datetime'];
        int parsedTime = isoToUnix(date ?? "");

        articles.add(
          Article(
            publisher: name,
            title: title?.trim() ?? "",
            content: "",
            excerpt: excerpt ?? "",
            author: author ?? "",
            url: url?.replaceFirst(homePage, "") ?? "",
            thumbnail: thumbnail ?? "",
            publishedAt: parsedTime,
            tags: tags,
            category: "",
          ),
        );
      }
    }
    return articles;
  }
}
