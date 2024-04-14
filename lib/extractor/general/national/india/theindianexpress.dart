import 'package:html/dom.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:raven/utils/time.dart';

class TheIndianExpress extends Publisher {
  @override
  String get name => "The Indian Express";

  @override
  String get homePage => "https://indianexpress.com";

  @override
  Future<Map<String, String>> get categories => extractCategories();

  @override
  Category get mainCategory => Category.india;

  @override
  bool get hasSearchSupport => false;

  Future<Map<String, String>> extractCategories() async {
    Map<String, String> map = {};
    var response = await http.get(Uri.parse(homePage));
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));
      document
          .querySelectorAll("#navbar a")
          .sublist(1)
          .forEach((element) {
        map.putIfAbsent(
          element.text.trim(),
          () {
            return element.attributes["href"]!
                .replaceFirst(homePage, "");
          },
        );
      });
    }
    var unsupported = ["Opinion", "Explained", "Entertainment", "Tech", "Research", "Videos"];
    return map..removeWhere((key, value) => !value.contains("section") || unsupported.contains(key));
  }

  @override
  Future<NewsArticle> article(NewsArticle newsArticle) async {
    var response = await http.get(Uri.parse("$homePage${newsArticle.url}"));
    if (response.statusCode == 200) {
      Document document = html_parser.parse(utf8.decode(response.bodyBytes));
      var content = document.querySelector("#pcl-full-content")?.innerHtml ?? "";
      var ads = ".osv-ad-class,.ad-slot,.subscriber_hide,.adboxtop,.pdsc-related-modify";
      document.querySelectorAll(ads).forEach((ad) {
        content = content.replaceAll(ad.innerHtml, "");
      },);
      var thumbnail = document.querySelector(".custom-caption img")?.attributes["content"];
      var excerpt = document.querySelector(".synopsis")?.text;
      var timestamp = document.querySelector("span[itemprop=dateModified]")?.attributes["content"];
      var tags = document.querySelectorAll(".m-breadcrumb a").sublist(1).map((e) => e.text).toList();
      return newsArticle.fill(
        content: content,
        thumbnail: thumbnail,
        excerpt: excerpt,
        publishedAt: parseDateString(timestamp??"", format: "yyyy-MM-ddTHH:mm:ssZ"),
        tags: tags,
      );
    }
    return newsArticle;
  }

  @override
  Future<Set<NewsArticle>> categoryArticles({
    String category = "/",
    int page = 1,
  }) async {
    if(category=="/")
      category = "/latest-news";

    Set<NewsArticle> articles = {};
    String url = "$homePage$category/page/$page";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Document document = html_parser.parse(utf8.decode(response.bodyBytes));
      List<Element> articleElements = [];
      if(page==1)
        articleElements = document.querySelectorAll(".swiper-slide") + document.querySelectorAll(".nation .articles");
      else
        articleElements = document.querySelectorAll(".nation .articles");
      for (var article in articleElements) {
        List<String> tags = [];
        var title = article.querySelector("a")?.text.trim() ?? "";
        if (title.trim().isEmpty)
          title = article.querySelector("h2 a")?.text.trim() ?? "";
        var articleUrl = article.querySelector("a")?.attributes["href"] ?? "";
        var thumbnail = article.querySelector("img")?.attributes["src"];
        var timestamp = article.querySelector(".date")?.text.replaceAll("  ", " ").trim() ?? "";
        var excerpt = article.querySelector(".date+p")?.text ?? "";
        timestamp = timestamp.contains("Updated:")?timestamp.split("Updated:")[1].trim():timestamp;
        articles.add(NewsArticle(
            publisher: this,
            title: title,
            content: "",
            excerpt: excerpt,
            author:  "",
            url: articleUrl.replaceFirst(homePage, ""),
            tags: tags,
            thumbnail: thumbnail ?? "",
            publishedAt: parseDateString(timestamp, format: "MMMM d, yyyy HH:mm z"),
            category: category),
        );
      }
    }
    return articles;
  }

  @override
  Future<Set<NewsArticle>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) async {
    return {};
  }
}
