import 'package:html/dom.dart';
import 'package:intl/intl.dart';
import 'package:whapp/model/article.dart';
import 'package:whapp/model/publisher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:whapp/utils/time.dart';

class Nitter extends Publisher {

  Map<String,String> headers = {
    'Host': 'nitter.net',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; rv:121.0) Gecko/20100101 Firefox/121.0',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.5',
  };

  @override
  String get homePage => "https://nitter.net";

  @override
  String get name => "Nitter";

  @override
  Future<Map<String, String>> get categories async => {};

  Future<Set<NewsArticle?>> extract(String category, int page,
      {String query = ""}) async {
    Set<NewsArticle?> articles = {};
    var dates = generateWeekDates(page);
    var response = await http.get(
      Uri.parse(
          "$homePage/$category/search?f=tweets&q=$query&since=${dates[0]}&until=${dates[1]}"),
      headers: headers
    );
    if (response.statusCode == 200) {
      Document document = html_parser.parse(utf8.decode(response.bodyBytes));
      List<Element> articleElements = document.querySelectorAll(".timeline-item");
      for (Element articleElement in articleElements) {
        String? title = articleElement
            .querySelector(".tweet-content")
            ?.text
            .split("\n")
            .first;
        String? excerpt = articleElement.querySelector(".tweet-content")?.text;
        String? author = articleElement.querySelector(".username")?.text;
        String? url =
            articleElement.querySelector(".tweet-link")?.attributes["href"];
        String? thumbnail = "";
        String? content = "";
        String? date =
            articleElement.querySelector(".tweet-date a")?.attributes["title"];
        String parsedTime =
            convertToIso8601("$date", "MMM d, yyyy · h:mm a UTC");

        articles.add(NewsArticle(
          this,
          title ?? "",
          content,
          excerpt ?? "",
          author ?? "",
          "$homePage$url",
          thumbnail,
          parseDateString(parsedTime),
        ));
      }
      return articles;
    }
    return articles;
  }

  @override
  Future<Set<NewsArticle?>> categoryArticles(
      {String category = "", int page = 1}) async {
    if (category.isEmpty || category == "/") return {};
    return extract(category, page);
  }

  @override
  Future<Set<NewsArticle?>> searchedArticles(
      {required String searchQuery, int page = 1}) async {
    if (!searchQuery.contains("#")) return {};
    return extract(searchQuery.split("#")[0], page,
        query: searchQuery.split("#")[1]);
  }

  @override
  Future<NewsArticle?> article(NewsArticle newsArticle) async {
    var response = await http.get(Uri.parse(newsArticle.url),
        headers: headers);
    if (response.statusCode == 200) {
      Document document = html_parser.parse(utf8.decode(response.bodyBytes));
      return newsArticle.fill(
          content: document.querySelector(".tweet-body")?.text ?? "");
    }
    return null;
  }

  List<String> generateWeekDates(int page) {
    DateTime currentDate = DateTime.now();
    DateTime untilDate;
    if (page == 1) {
      untilDate = currentDate;
    } else {
      untilDate = currentDate.subtract(Duration(days: 7 * (page - 1)));
    }
    DateTime sinceDate = untilDate.subtract(Duration(days: 7));
    String sinceDateString = DateFormat('yyyy-MM-dd').format(sinceDate);
    String untilDateString = DateFormat('yyyy-MM-dd').format(untilDate);
    return [sinceDateString, untilDateString];
  }
}
