import 'package:html/dom.dart';
import 'package:whapp/model/article.dart';
import 'package:whapp/model/publisher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:whapp/utils/time.dart';

class ArsTechnica extends Publisher {
  @override
  String get homePage => "https://arstechnica.com";

  @override
  String get name => "Ars Technica";

  @override
  String get mainCategory => "Technology";

  @override
  Future<NewsArticle?> article(NewsArticle newsArticle) async {
    var response = await http.get(Uri.parse("$homePage${newsArticle.url}"));
    if (response.statusCode == 200) {
      Document document = html_parser.parse(utf8.decode(response.bodyBytes));
      String? thumbnail = document.querySelector(".figure img")?.attributes["href"];
      String? content = document.querySelectorAll(".article-content p").map((e) => e.innerHtml).join("<br><br>");
      return newsArticle.fill(content: content, thumbnail: thumbnail);
    }
    return null;
  }

  @override
  Future<Map<String, String>> get categories async => {
    "News": "",
    "Reviews": "reviews",
    "Guides": "guides",
    "Gaming": "gaming",
    "Gear": "gear",
    "Entertainment": "entertainment",
    "Tomorrow": "tomorrow",
    "Deals": "deals",
  };

  @override
  bool get hasSearchSupport => false;

  @override
  Future<Set<NewsArticle?>> categoryArticles({String category = "", int page = 1}) async {
    Set<NewsArticle> articles = {};
    if(category.isNotEmpty) {
      category="/$category";
    }

    var response = await http.get(Uri.parse("$homePage$category/page/$page"));
    if (response.statusCode == 200) {
      Document document = html_parser.parse(utf8.decode(response.bodyBytes));
      List<Element> articleElements =
      document.querySelectorAll(".article");
      for (Element articleElement in articleElements) {
        String? title = articleElement.querySelector("h2 a")?.text;
        String? excerpt = articleElement.querySelector(".excerpt")?.text;
        String? author = articleElement.querySelector("span[itemprop=name]")?.text;
        String? date = articleElement.querySelector("time")?.attributes["datetime"] ?? "";
        String? url = articleElement.querySelector("h2 a")?.attributes["href"];
        String? thumbnail = articleElement
            .querySelector("figure div")
            ?.attributes["style"];

        articles.add(NewsArticle(
          publisher: this,
          title: title ?? "",
          content: "",
          excerpt: excerpt ?? "",
          author: author ?? "",
          url: url?.replaceFirst(homePage, "") ?? "",
          thumbnail: extractUrl(thumbnail),
          publishedAt: parseDateString(date),
        ));

      }
    }
    return articles;
  }

  String extractUrl(String? inputString) {
    RegExp regExp = RegExp(r"url\('([^']*)'\)");
    if(inputString!=null) {
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
  Future<Set<NewsArticle?>> searchedArticles({required String searchQuery, int page = 1}) async{
    return {};
  }
}
