import 'package:html/dom.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:raven/utils/time.dart';

class BleepingComputer extends Publisher {
  @override
  String get homePage => "https://www.bleepingcomputer.com";

  @override
  String get name => "BleepingComputer";

  @override
  String get mainCategory => "Technology";

  @override
  Future<NewsArticle> article(NewsArticle newsArticle) async {
    var response = await http.get(Uri.parse("$homePage${newsArticle.url}"));
    if (response.statusCode == 200) {
      Document document = html_parser.parse(utf8.decode(response.bodyBytes));
      String? thumbnail = "";
      String? content = document
          .querySelectorAll(".articleBody > :not(.cz-related-article-wrapp)")
          .toList()
          .map((e) => e.innerHtml)
          .join("<br><br>");
      return newsArticle.fill(content: content, thumbnail: thumbnail,);
    }
    return newsArticle;
  }

  @override
  bool get hasSearchSupport => false;

  @override
  Future<Map<String, String>> get categories async => {};

  @override
  Future<Set<NewsArticle>> categoryArticles({String category = "", int page = 1}) async {
    Set<NewsArticle> articles = {};
    var response = await http.get(Uri.parse(page!=1?"$homePage/news/page/$page":"$homePage/news/"));
    if (response.statusCode == 200) {
      Document document = html_parser.parse(utf8.decode(response.bodyBytes));
      List<Element> articleElements =
          document.querySelectorAll("#bc-home-news-main-wrap > li");
      for (Element articleElement in articleElements) {
        String? title = articleElement.querySelector("h4")?.text;
        String? excerpt = articleElement.querySelector("p")?.text;
        String? author = articleElement.querySelector(".author")?.text;
        String? url = articleElement.querySelector("h4 a")?.attributes["href"];
        var tags = articleElement.querySelectorAll(".bc_latest_news_category span a").map((e) => e.text).toList();
        String? thumbnail = articleElement
                .querySelector(".bc_latest_news_img img")
                ?.attributes["src"];
        if (thumbnail!=null && thumbnail.endsWith("==")) {
          thumbnail = articleElement
              .querySelector(".bc_latest_news_img img")
              ?.attributes["data-src"];
        }
        String? content = "";
        String? date = articleElement.querySelector(".bc_news_date")?.text;
        String? time = articleElement.querySelector(".bc_news_time")?.text;
        String parsedTime = convertToIso8601("$date $time", "MMMM dd, yyyy hh:mm a");

        articles.add(NewsArticle(
          publisher: this,
          title: title ?? "",
          content: content,
          excerpt: excerpt ?? "",
          author: author ?? "",
          url: url?.replaceFirst(homePage, "") ?? "",
          thumbnail: thumbnail ?? "",
          publishedAt: parseDateString(parsedTime),
          tags: tags
        ));

      }
    }
    return articles;
  }

  @override
  Future<Set<NewsArticle>> searchedArticles({required String searchQuery, int page = 1}) async{
    return {};
  }
}
