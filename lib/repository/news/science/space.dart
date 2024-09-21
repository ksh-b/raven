import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/model/article.dart';
import 'package:raven/model/category.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/time.dart';

class Space extends Publisher {
  @override
  String get homePage => "https://www.space.com";

  @override
  String get name => "Space";

  @override
  String get mainCategory => Category.science.name;

  @override
  bool get hasSearchSupport => true;

  @override
  Future<Map<String, String>> get categories async {
    Map<String, String> map = {};
    var response = await dio().get(homePage);
    if (response.successful) {
      var document = html_parser.parse(response.data);
      document
          .querySelectorAll(".menuitems li a").sublist(1)
          .forEach((element) {
        map.putIfAbsent(
          element.text.trim(),
              () {
            return element.attributes["href"]!.replaceFirst(homePage, "");
          },
        );
      });
    }
    return map..removeWhere((key, value) => value.contains(".space") || value.contains(".html") || value.contains(".com"));
  }

  @override
  Future<Article> article(Article newsArticle) async {
    var response = await dio().get("$homePage${newsArticle.url}");
    if (response.successful) {
      Document document = html_parser.parse(response.data);
      String? thumbnail = document.querySelector("picture img")?.attributes['src'];
      String? content = document.querySelector("#article-body")?.text;
      String? excerpt = document.querySelector(".strapline")?.text;
      newsArticle = newsArticle.fill(
        content: content,
        thumbnail: thumbnail,
        excerpt: excerpt
      );
    }
    return newsArticle;
  }

  @override
  Future<Set<Article>> categoryArticles({
    String category = "/",
    int page = 1,
  }) async {
    Set<Article> articles = {};
    var response = await dio()
        .get("$homePage$category/page/$page");

    if (response.successful) {
      Document document = html_parser.parse(response.data);
      List<Element> articleElements =
      document.querySelectorAll(".listingResult");
      for (Element articleElement in articleElements) {
        String? title = articleElement.querySelector("h3")?.text;
        if(title==null)
          continue;
        String? excerpt = articleElement.querySelector(".synopsis")?.text ?? "";
        String? author = articleElement.querySelector(".by-author span")?.text ?? "";
        String? url = articleElement.querySelector(".article-link")?.attributes["href"];
        var tags = articleElement
            .querySelectorAll(".category-link")
            .map((e) => e.text)
            .toList().sublist(0);
        String? thumbnail = articleElement
            .querySelector("picture img")
            ?.attributes["src"];
        String? content = "";
        String? date = articleElement.querySelector("time")?.attributes['datetime'] ?? "";
        int parsedTime = isoToUnix(
          date
        );

        articles.add(
          Article(
            publisher: name,
            title: title,
            content: content,
            excerpt: excerpt,
            author: author,
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
    var response = await dio()
        .get("$homePage/search/page/$page?searchTerm=$searchQuery");

    if (response.successful) {
      Document document = html_parser.parse(response.data);
      List<Element> articleElements =
      document.querySelectorAll(".listingResult");
      for (Element articleElement in articleElements) {
        String? title = articleElement.querySelector("h3")?.text;
        String? excerpt = articleElement.querySelector(".synopsis")?.text ?? "";
        String? author = articleElement.querySelector(".by-author span")?.text ?? "";
        String? url = articleElement.querySelector(".article-link")?.attributes["href"];
        var tags = articleElement
            .querySelectorAll(".category-link")
            .map((e) => e.text)
            .toList().sublist(0);
        String? thumbnail = articleElement
            .querySelector("picture img")
            ?.attributes["src"];
        String? content = "";
        String? date = articleElement.querySelector("time")?.attributes['datetime'] ?? "";
        int parsedTime = isoToUnix(
            date
        );

        articles.add(
          Article(
            publisher: name,
            title: title ?? "",
            content: content,
            excerpt: excerpt,
            author: author,
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
