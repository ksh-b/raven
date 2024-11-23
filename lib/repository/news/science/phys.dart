import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/model/article.dart';
import 'package:raven/model/category.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/time.dart';

class Phys extends Publisher {
  @override
  String get homePage => "https://phys.org";

  @override
  String get name => "Phys";

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
          .querySelectorAll("#secondaryNav .nav-link[href*=phys]")
          .forEach((element) {
        map.putIfAbsent(
          element.text.trim(),
              () {
            return element.attributes["href"]!.replaceFirst(homePage, "");
          },
        );
      });
    }
    return map;
  }

  @override
  Future<Article> article(Article newsArticle) async {
    var response = await dio().get(newsArticle.url);
    if (response.successful) {
      Document document = html_parser.parse(response.data);
      String? thumbnail = "";
      String? content = document.querySelector(".article-main")?.text;
      newsArticle = newsArticle.fill(
        content: content,
        thumbnail: thumbnail,
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
        .get("$homePage$category/page$page.html?l=0");

    if (response.successful) {
      Document document = html_parser.parse(response.data);
      List<Element> articleElements =
          document.querySelectorAll(".sorted-article");
      for (Element articleElement in articleElements) {
        String? title = articleElement.querySelector("h3 a")?.text;
        String? excerpt = "";
        String? author = "";
        String? url = articleElement.querySelector("h3 a")?.attributes["href"];
        var tags = articleElement
            .querySelectorAll(".article__info p")
            .map((e) => e.text)
            .toList().sublist(0);
        String? thumbnail = articleElement
            .querySelector("figure img")
            ?.attributes["src"];
        String? content = articleElement.querySelector("h3+p")?.text;
        String? date = articleElement.querySelector("svg~p")?.text.trim() ?? "";
        int parsedTime = -1;
        if(date.contains("ago")) {
          parsedTime = relativeStringToUnix(
            date,
          );
        } else {
          parsedTime = stringToUnix(
            date,
            format: "MMMM dd, yyyy",
          );
        }

        articles.add(
          Article(
            publisher: name,
            title: title ?? "",
            content: content ?? "",
            excerpt: excerpt,
            author: author,
            url: url ?? "",
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
        .get("$homePage/search/page$page.html?search=$searchQuery&s=0");

    if (response.successful) {
      Document document = html_parser.parse(response.data);
      List<Element> articleElements =
      document.querySelectorAll(".sorted-article");
      for (Element articleElement in articleElements) {
        String? title = articleElement.querySelector("h4 a")?.text;
        String? excerpt = "";
        String? author = "";
        String? url = articleElement.querySelector("h4 a")?.attributes["href"];
        var tags = articleElement
            .querySelectorAll(".text-info")
            .map((e) => e.text)
            .toList().sublist(0);
        String? thumbnail = articleElement
            .querySelector("figure img")
            ?.attributes["src"];
        String? content = articleElement.querySelector("h4+p")?.text;
        String? date = articleElement.querySelector(".text-muted+.text-muted")?.text ?? "";
        int parsedTime = -1;
        if(date.contains("ago")) {
          parsedTime = relativeStringToUnix(
            date,
          );
        } else {
          parsedTime = stringToUnix(
            date,
            format: "MMMM dd, yyyy",
          );
        }
        articles.add(
          Article(
            publisher: name,
            title: title ?? "",
            content: content ?? "",
            excerpt: excerpt,
            author: author,
            url: url ?? "",
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
