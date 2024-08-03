import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/brain/dio_manager.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/utils/time.dart';

class AndroidPolice extends Publisher {
  @override
  String get homePage => "https://www.androidpolice.com";

  @override
  String get name => "Android Police";

  @override
  Category get mainCategory => Category.technology;

  @override
  String get iconUrl => "https://www.androidpolice.com/public/build/images/favicon-48x48.52dff51b.png";

  @override
  Future<NewsArticle> article(NewsArticle newsArticle) async {
    await dio().get("$homePage${newsArticle.url}").then((response) {
      if (response.statusCode == 200) {
        Document document = html_parser.parse(response.data);
        String? content = document.querySelector(".article-body")?.innerHtml;
        List<String> related = document.querySelectorAll(".no-badge.small").map((e) => e.innerHtml).toList();
        for (String rel in related) {
          content = content?.replaceFirst(rel, "");
        }
        newsArticle = newsArticle.fill(
          content: content,
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
          document.querySelectorAll("a[class*='sidenav-link']")
              .forEach((element) {
            map.putIfAbsent(
              element.text.trim(),
                  () {
                return element.attributes["href"]!;
              },
            );
          });
        }
      },
    );
    var unsupported = ["Sign in", "Newsletter"];
    return map..removeWhere((key, value) => unsupported.contains(key));
  }

  @override
  Future<Set<NewsArticle>> categoryArticles(
      {String category = "", int page = 1}) async {
    Set<NewsArticle> articles = {};
    await dio().get("$homePage/$category/$page").then((response) {
      if (response.statusCode == 200) {
        Document document = html_parser.parse(response.data);
        List<Element> articleElements =
        document.querySelectorAll(".listing-content .article");
        for (Element articleElement in articleElements) {
          String? title = articleElement.querySelector(".display-card-title")?.text;
          String? excerpt = articleElement.querySelector(".display-card-excerpt")?.text;
          String? author = articleElement.querySelector(".display-card-author")?.text;
          String? url = articleElement.querySelector(".display-card-title a")?.attributes["href"];
          var tags = articleElement
              .querySelectorAll(".listing-title")
              .map((e) => e.text)
              .toList();
          String? thumbnail = articleElement
              .querySelector("picture img")
              ?.attributes["src"];
          String? content = articleElement.querySelector(".display-card-firstParagraph")?.text;
          String? date = articleElement.querySelector(".display-card-date")?.text;
          int parsedTime = relativeStringToUnix(date??"");

          articles.add(NewsArticle(
              publisher: name,
              title: title?.trim() ?? "",
              content: content ?? "",
              excerpt: excerpt ?? "",
              author: author ?? "",
              url: url?.replaceFirst(homePage, "") ?? "",
              thumbnail: thumbnail ?? "",
              publishedAt: parsedTime,
              tags: tags,
              category: category));
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
        List<Element> articleElements =
        document.querySelectorAll(".listing-content .article");
        for (Element articleElement in articleElements) {
          String? title = articleElement.querySelector(".display-card-title")?.text;
          String? excerpt = articleElement.querySelector(".display-card-excerpt")?.text;
          String? author = articleElement.querySelector(".display-card-author")?.text;
          String? url = articleElement.querySelector(".display-card-title a")?.attributes["href"];
          var tags = articleElement
              .querySelectorAll(".listing-title")
              .map((e) => e.text)
              .toList();
          String? thumbnail = articleElement
              .querySelector("picture img")
              ?.attributes["src"];
          String? date = articleElement.querySelector(".display-card-date")?.text;
          int parsedTime = relativeStringToUnix(date??"");

          articles.add(NewsArticle(
              publisher: name,
              title: title?.trim() ?? "",
              content: "",
              excerpt: excerpt ?? "",
              author: author ?? "",
              url: url?.replaceFirst(homePage, "") ?? "",
              thumbnail: thumbnail ?? "",
              publishedAt: parsedTime,
              tags: tags,
              category: searchQuery));
        }
      }
    });

    return articles;
  }
}
