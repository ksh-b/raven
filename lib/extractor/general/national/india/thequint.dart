import 'package:html/dom.dart';
import 'package:whapp/model/article.dart';
import 'package:whapp/model/publisher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:whapp/utils/time.dart';

class TheQuint extends Publisher {
  @override
  String get name => "The Quint";

  @override
  String get homePage => "https://www.thequint.com";

  @override
  Future<Map<String, String>> get categories => extractCategories();

  @override
  String get mainCategory => "India";

  Future<Map<String, String>> extractCategories() async {
    Map<String, String> map = {};
    var response = await http.get(Uri.parse(homePage));
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));

      document
          .querySelectorAll('#second-nav-bar a[id*=ga4-header]')
          .forEach((element) {
        map.putIfAbsent(
          element.text,
          () {
            return element.attributes["href"]!
                .replaceFirst("/", "")
                .replaceFirst("news/", "");
          },
        );
      });
    }
    return map;
  }

  @override
  Future<NewsArticle?> article(NewsArticle newsArticle) async {
    var response = await http.get(Uri.parse("$homePage${newsArticle.url}"));
    if (response.statusCode == 200) {
      Document document = html_parser.parse(utf8.decode(response.bodyBytes));
      var content = document.querySelectorAll(".story-element-text p,blockquote");
      var thumbnail = document.querySelector("picture img")?.attributes["src"];
      return newsArticle.fill(
        content: content.map((e) => e.innerHtml).join("<br><br>"),
        thumbnail: thumbnail,
      );
    }
    return null;
  }

  @override
  Future<Set<NewsArticle?>> categoryArticles({
    String category = "/",
    int page = 1,
  }) async {
    Set<NewsArticle?> articles = {};
    var limit = 10;
    var offset = limit * (page-1);
    if(category=="/") {
      category = "india";
    }
    String url = "$homePage/api/v1/collections/$category?limit=$limit&offset=$offset";
    
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List data = json.decode(response.body)["items"];

      for (var element in data) {
        if(element["story"]==null) continue;
        var title = element["story"]['headline'];
        var author = element['story']["author-name"];
        var thumbnail = "https://images.quint.com/${element['story']['hero-image-s3-key']}";
        var time = element['story']["last-published-at"];
        var articleUrl = element['story']["url"] ?? "";
        var excerpt = element['story']['summary'] ?? "";
        articles.add(NewsArticle(
          publisher: this,
          title: title ?? "",
          content: "",
          excerpt: excerpt,
          author: author ?? "",
          url: articleUrl.replace(homePage, ""),
          thumbnail: thumbnail,
          publishedAt: parseUnixTime(time),
        ));
      }
    }
    return articles;
  }

  @override
  Future<Set<NewsArticle?>> searchedArticles(
      {required String searchQuery, int page = 1,}) async {
    Set<NewsArticle?> articles = {};
    String apiUrl = '$homePage/route-data.json?path=/search&q=$searchQuery';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      List data= json.decode(response.body)["data"]["stories"];

      for (var element in data) {
        var title = element['headline'];
        var author = element['authors'][0]["name"];
        var thumbnail = "https://images.quint.com/${element['hero-image-s3-key']}";
        var time = element["last-published-at"];
        var articleUrl = element["url"];
        articles.add(NewsArticle(
          publisher: this,
          title: title ?? "",
          content: "",
          excerpt: "",
          author: author ?? "",
          url: articleUrl.replace(homePage, ""),
          thumbnail: thumbnail,
          publishedAt: parseUnixTime(time),
        ));
      }
    }
    return articles;
  }

}
