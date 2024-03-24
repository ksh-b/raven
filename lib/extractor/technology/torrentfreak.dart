import 'package:intl/intl.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:raven/utils/time.dart';

class TorrentFreak extends Publisher {
  @override
  String get name => "TorrentFreak";

  @override
  String get homePage => "https://torrentfreak.com";

  @override
  Future<Map<String, String>> get categories => extractCategories();

  @override
  String get mainCategory => "Technology";

  Future<Map<String, String>> extractCategories() async {
    Map<String, String> map = {};
    var response = await http.get(Uri.parse(homePage));
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));

      document.querySelectorAll('.sub-menu a').forEach((element) {
        map.putIfAbsent(
          element.text,
          () {
            var splitUrl = element.attributes["href"]!.split("/");
            splitUrl.removeWhere((e) => e.isEmpty,);
            return splitUrl.last;
          },
        );
      });
    }
    return map;
  }

  @override
  Future<NewsArticle> article(NewsArticle newsArticle) async {
    var response = await http.get(Uri.parse('$homePage${newsArticle.url}'));
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));

      var articleElement = document.querySelector('.article__body');
      var excerptElement = document.querySelector('.article__excerpt');
      var thumbnailElement = document.querySelector('section[data-bg]');
      var content = articleElement?.innerHtml;
      var excerpt = excerptElement?.text;
      var thumbnail = thumbnailElement?.attributes["data-bg"];
      return newsArticle.fill(
        content: content,
        excerpt: excerpt,
        thumbnail: thumbnail,
      );
    }
    return newsArticle;
  }

  @override
  Future<Set<NewsArticle>> articles({String category = "", int page = 1}) async {
    return super.articles(category: category, page: page);
  }

  Future<Set<NewsArticle>> extract(String url) async {
    Set<NewsArticle> articles = {};
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));
    
      var articleElements = document.querySelectorAll('.preview-article');
      for (var element in articleElements) {
        var titleElement = element.querySelector('.preview-article__title');
        var authorElement =
            element.querySelector('.preview-article__published span');
        var thumbnailElement = element.querySelector('img');
        var articleUrlElement = element.querySelector('a');
        var timeElement =
            element.querySelector('.preview-article__published time');
        var title = titleElement?.text;
        var author = authorElement?.text;
        var thumbnail = thumbnailElement?.attributes["src"];
        var time = timeElement?.attributes["datetime"] ?? timeElement?.text;
        var articleUrl = articleUrlElement?.attributes["href"];
        var tags = articleUrlElement?.querySelectorAll(".preview-article__category").map((e) => e.text).toList()??[];

        if (time!=null) {
          if (time.contains("today")) {
            time = DateTime.now().toIso8601String();
          } else if (time.contains("yesterday")) {
            time = DateTime.now().subtract(Duration(days: 1)).toIso8601String();
          } else {
            DateTime parsedDateTime = DateFormat("MMMM d, y, HH:mm").parse(time);
            time = DateFormat("yyyy-MM-dd HH:mm:ss").format(parsedDateTime);
          }
        }

        articles.add(NewsArticle(
          publisher: this,
          title: title ?? "",
          content: "",
          excerpt: "",
          author: author ?? "",
          url: articleUrl?.replaceFirst(homePage, "") ?? "",
          thumbnail: thumbnail ?? "",
          publishedAt: parseDateString(time?.trim() ?? ""),
          tags: tags
        ));

      }
    }
    return articles;
  }

  @override
  Future<Set<NewsArticle>> categoryArticles({String category = "/", int page = 1}) {
    String categoryPath = category.isNotEmpty&&category!="/"?"/category/$category":"";
    var url = '$homePage$categoryPath/page/$page';
    return extract(url);
  }

  @override
  Future<Set<NewsArticle>> searchedArticles({required String searchQuery, int page = 1}) {
    return extract("$homePage/page/$page/?s=$searchQuery");
  }
}
