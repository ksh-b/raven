import 'package:whapp/model/article.dart';
import 'package:whapp/model/publisher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:whapp/utils/string.dart';
import 'package:whapp/utils/time.dart';

class Reuters extends Publisher {
  @override
  String get name => "Reuters";

  @override
  String get homePage => "https://www.reuters.com";

  @override
  Future<Map<String, String>> get categories => extractCategories();


  Future<Map<String, String>> extractCategories() async {
    return {
      "World": "world",
      "Business": "business",
      "Markets": "markets",
      "Sustainability": "sustainability",
      "Legal": "legal",
      "Breakingviews": "breakingviews",
      "Technology": "technology",
      "Sports": "sports",
      "Science": "science",
      "Lifestyle": "lifestyle",
    };
  }

  @override
  Future<NewsArticle?> article(String url) async {
    var response = await http.get(Uri.parse('https://neuters.de$url'));
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));

      var titleElement = document.querySelector('h1');
      var articleElement = document.querySelectorAll('p:not(.byline)');
      var timeAuthorElement = document.querySelector('.byline');
      var title = titleElement?.text;
      var article = articleElement.map((e) => e.text).join("\n");
      var author = timeAuthorElement?.text.split(" - ")[1];
      var excerpt = "";
      var thumbnail = "";
      var time = timeAuthorElement?.text.split(" - ")[0];
      return NewsArticle(
        this,
        title ?? "",
        article,
        excerpt,
        author ?? "",
        url,
        thumbnail,
        parseDateString(time?.trim() ?? ""),
      );
    }
    return null;
  }

  @override
  Future<Set<NewsArticle?>> articles({
    String category = "world",
    int page = 1,
  }) async {
    return super.articles(category: category, page: page);
  }

  Future<Set<NewsArticle?>> extract(
    String apiUrl,
  ) async {
    Set<NewsArticle?> articles = {};

    List articlesData = [];
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      articlesData = data["result"]["articles"];
      for (var element in articlesData) {
        var title = element['title'];
        var author = element['authors'][0]["name"];
        var thumbnail = element.keys.contains("thumbnail")
            ? element['thumbnail']['url']
            : "";
        var time = element["published_time"];
        var articleUrl = '${element['canonical_url']}';
        var excerpt = element['description'];
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
  Future<Set<NewsArticle?>> categoryArticles({
    String category = "All",
    int page = 1,
  }) {
    if (category == "/") {
      category = "world";
    }
    String apiUrl =
        '$homePage/pf/api/v3/content/fetch/recent-stories-by-sections-v1?'
        'query={"section_ids":"/$category/","offset": ${(page-1)*10},'
        '"size":10,'
        '"website":"reuters"}';

    return extract(apiUrl);
  }

  @override
  Future<Set<NewsArticle?>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) {
    searchQuery = getAsSearchQuery(searchQuery);
    String apiUrl =
        'https://www.reuters.com/pf/api/v3/content/fetch/articles-by-search-v2?'
        'query={"keyword":"$searchQuery","offset":${(page-1)*20},'
        '"orderby":"display_date:desc","size":20,"website":"reuters"}'
        '&d=168&_website=reuters';
    return extract(apiUrl);
  }
}
