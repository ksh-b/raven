import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/brain/dio_manager.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/utils/string.dart';
import 'package:raven/utils/time.dart';

class GHacks extends Publisher {
  @override
  String get homePage => "https://www.ghacks.net";

  @override
  String get name => "gHacks";

  @override
  Category get mainCategory => Category.technology;

  @override
  Future<NewsArticle> article(NewsArticle newsArticle) async {
    await dio().get("$homePage${newsArticle.url}").then((response) {
      if (response.statusCode == 200) {
        Document document = html_parser.parse(response.data);
        String? thumbnail = "";
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
          thumbnail: thumbnail,
        );
      }
    });

    return newsArticle;
  }

  @override
  bool get hasSearchSupport => false;

  @override
  Future<Map<String, String>> get categories async {
    Map<String, String> map = {};
    await dio().get(homePage).then(
      (response) {
        if (response.statusCode == 200) {
          var document = html_parser.parse(response.data);
          document
              .querySelectorAll(".top-navigation a")
              .skip(1)
              .forEach((element) {
            map.putIfAbsent(
              element.text.trim(),
              () {
                return element.attributes["href"]!.replaceFirst(homePage, "");
              },
            );
          });
        }
      },
    );
    return map..removeWhere((key, value) => key == "VPNs");
  }

  @override
  Future<Set<NewsArticle>> categoryArticles(
      {String category = "", int page = 1}) async {
    Set<NewsArticle> articles = {};
    await dio()
        .get("$homePage${category}latest-posts/page/$page/")
        .then((response) {
      if (response.statusCode == 200) {
        Document document = html_parser.parse(response.data);
        List<Element> articleElements =
            document.querySelectorAll(".home-category-post");
        for (Element articleElement in articleElements) {
          String? title = articleElement.querySelector("h3")?.text;
          String? author = findStringBetween(
            articleElement.querySelector(".home-intro-post-meta")?.text ?? "",
            " by ",
            " on ",
          );
          String? url = articleElement.querySelector("h3")?.attributes["href"];
          var tags = articleElement
              .querySelectorAll("#breadcrumbs a[href*=category]")
              .map((e) => e.text)
              .toList();
          String? thumbnail =
              articleElement.querySelector("img")?.attributes["src"];
          String? date = findStringBetween(
            articleElement.querySelector(".home-intro-post-meta")?.text ?? "",
            " on ",
            " in ",
          );
          int parsedTime = stringToUnix(date, format: "MMM dd, yyyy");

          articles.add(
            NewsArticle(
              publisher: name,
              title: title ?? "",
              content: "",
              excerpt: "",
              author: author,
              url: url?.replaceFirst(homePage, "") ?? "",
              thumbnail: thumbnail ?? "",
              publishedAt: parsedTime,
              tags: category.split("/")..skip(1),
              category: category,
            ),
          );
        }
      }
    });
    return articles;
  }

  @override
  Future<Set<NewsArticle>> searchedArticles(
      {required String searchQuery, int page = 1}) async {
    Set<NewsArticle> articles = {};
    await dio().get("$homePage/search/?q=$searchQuery").then((response) {
      if (response.statusCode == 200) {
        Document document = html_parser.parse(response.data);
        List<Element> articleElements = document.querySelectorAll(".hentry");
        for (Element articleElement in articleElements) {
          String? title = articleElement.querySelector("h3")?.text;
          String? url = articleElement.attributes["href"];
          var tags = findStringBetween(
              articleElement.querySelector(".ghacks-links")?.text ?? "",
              " in ",
              "-");
          String? thumbnail =
              articleElement.querySelector("img")?.attributes["src"];
          String? date = findStringBetween(
            articleElement.querySelector(".display-card-date")?.text ?? "",
            " on ",
            " in ",
          );
          int parsedTime = stringToUnix(date, format: "MMM dd, yyyy");

          articles.add(NewsArticle(
              publisher: name,
              title: title ?? "",
              content: "",
              excerpt: "",
              author: "",
              url: url?.replaceFirst(homePage, "") ?? "",
              thumbnail: thumbnail ?? "",
              publishedAt: parsedTime,
              tags: [tags],
              category: searchQuery));
        }
      }
    });
    return articles;
  }
}
