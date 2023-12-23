import 'package:whapp/model/article.dart';
import 'package:whapp/model/publisher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:whapp/utils/time.dart';

class TheWire extends Publisher {
  @override
  String get name => "The Wire";

  @override
  String get homePage => "https://thewire.in";

  @override
  Future<Map<String, String>> get categories => extractCategories();

  @override
  String get iconUrl => "$homePage/favicon-32x32.png";

  @override
  String get searchEndpoint => "/search";

  Future<Map<String, String>> extractCategories() async {
    Map<String, String> map = {};
    var response = await http.get(Uri.parse(homePage));
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));

      document.querySelectorAll('.wire-subheader a').forEach((element) {
        map.putIfAbsent(
          element.text,
          () {
            return element.attributes["href"]!
                .replaceFirst("/", "")
                .replaceFirst("/all", "");
          },
        );
      });
    }
    return map;
  }

  @override
  Future<NewsArticle?> article(String url) async {
    var response = await http
        .get(Uri.parse('$homePage/wp-json/thewire/v2/posts/detail/$url'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var postDetail = data["post-detail"][0];
      var title = postDetail["post_title"];
      var article = postDetail["post_content"];
      var author = postDetail["post_author_name"][0]["author_name"];
      var excerpt = postDetail["post_excerpt"];
      var thumbnail = postDetail["featured_image"][0];
      var time = postDetail["post_date_gmt"];
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
  Future<Set<NewsArticle?>> articles(
      {String category = "home", int page = 1}) async {
    return super.articles(category: category, page: page);
  }

  Future<Set<NewsArticle?>> extract(
      String apiUrl, Map<String, String> params, bool isSearch) async {
    Set<NewsArticle?> articles = {};
    final response = await http.get(Uri.parse(apiUrl), headers: params);
    if (response.statusCode == 200) {
      List data;
      if (isSearch) {
        data = json.decode(response.body)["generic"];
      } else {
        data = json.decode(response.body);
      }
      for (var element in data) {
        var title = element['post_title'];
        var author = element['post_author_name'][0]["author_name"];
        var thumbnail = element['hero_image'][0]; //element['thumbnail']['url'];
        var time = element["post_date_gmt"];
        var articleUrl = '${element['post_name']}';
        var excerpt = element['post_excerpt'];
        articles.add(NewsArticle(
          this,
          title ?? "",
          "",
          excerpt,
          author ?? "",
          articleUrl,
          thumbnail ?? "",
          parseDateString(time?.trim() ?? ""),
        ));
      }
    }
    return articles;
  }

  @override
  Future<Set<NewsArticle?>> categoryArticles(
      {String category = "All", int page = 1}) async {
    if (category == '/') {
      category = 'home';
    }
    String apiUrl =
        '$homePage/wp-json/thewire/v2/posts/$category/recent-stories';
    Map<String, String> params = {
      'per_page': '10',
      'page': '$page',
    };
    return extract(apiUrl, params, false);
  }

  @override
  Future<Set<NewsArticle?>> searchedArticles(
      {required String searchQuery, int page = 1}) {
    String apiUrl = '$homePage/wp-json/thewire/v2/posts$searchEndpoint';
    Map<String, String> params = {
      'keyword': searchQuery,
      'orderby': 'rel',
      'per_page': '5',
      'page': '1',
      'type': 'opinion',
    };
    return extract(apiUrl, params, true);
  }
}
