import 'package:intl/intl.dart';
import 'package:whapp/model/article.dart';
import 'package:whapp/model/publisher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:whapp/utils/time.dart';

class TorrentFreak extends Publisher {
  @override
  String get name => "TorrentFreak";

  @override
  String get homePage => "https://torrentfreak.com";

  @override
  Future<Map<String, String>> get categories => extractCategories();

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
  Future<NewsArticle?> article(String url) async {
    var response = await http.get(Uri.parse('$homePage$url'));
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));

      var titleElement = document.querySelector('.hero__title');
      var articleElement = document.querySelector('.article__body');
      var authorElement = document.querySelector('.hero__published a');
      var excerptElement = document.querySelector('.article__excerpt');
      var thumbnailElement = document.querySelector('section[data-bg]');
      var timeElement = document.querySelector('time');
      var title = titleElement?.text;
      var article = articleElement?.innerHtml;
      var author = authorElement?.text;
      var excerpt = excerptElement?.text;
      var thumbnail = thumbnailElement?.attributes["data-bg"];
      var time = timeElement?.text;

      return NewsArticle(
        this,
        title ?? "",
        article ?? "",
        excerpt ?? "",
        author ?? "",
        url,
        thumbnail ?? "",
        parseDateString(time?.trim() ?? ""),
      );
    }
    return null;
  }

  @override
  Future<Set<NewsArticle?>> articles({String category = "", int page = 1}) async {
    return super.articles(category: category, page: page);
  }

  Future<Set<NewsArticle?>> extract(String url) async {
    Set<NewsArticle?> articles = {};
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

        if (time!=null) {
          if (time.contains("yesterday")) {
            time = DateTime.now().subtract(Duration(days: 1)).toIso8601String();
          } else {
            DateTime parsedDateTime = DateFormat("MMMM d, y, HH:mm").parse(time);
            time = DateFormat("yyyy-MM-dd HH:mm:ss").format(parsedDateTime);
          }
        }

        articles.add(NewsArticle(
          this,
          title ?? "",
          "",
          "",
          author ?? "",
          articleUrl?.replaceFirst(homePage, "") ?? "",
          thumbnail ?? "",
          parseDateString(time?.trim() ?? ""),
        ));
      }
    }
    return articles;
  }

  @override
  Future<Set<NewsArticle?>> categoryArticles({String category = "/", int page = 1}) {
    String categoryPath = category.isNotEmpty&&category!="/"?"/category/$category":"";
    var url = '$homePage$categoryPath/page/$page';
    return extract(url);
  }

  @override
  Future<Set<NewsArticle?>> searchedArticles({required String searchQuery, int page = 1}) {
    return extract("$homePage/page/$page/?s=$searchQuery");
  }
}
