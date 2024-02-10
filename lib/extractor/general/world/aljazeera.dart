import 'package:whapp/model/article.dart';
import 'package:whapp/model/publisher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:whapp/utils/time.dart';

class AlJazeera extends Publisher {
  @override
  String get name => "Al Jazeera";

  @override
  String get homePage => "https://www.aljazeera.com";

  @override
  Future<Map<String, String>> get categories => extractCategories();

  @override
  bool get hasSearchSupport => false;

  @override
  String get mainCategory => "World";

  Future<Map<String, String>> extractCategories() async {
    return {
      "Features": "features",
      "Economy": "economy",
      "Opinion": "opinion",
      "Science & Technology": "tag/science-and-technology",
      "Sport": "sports",
    };
  }

  @override
  Future<NewsArticle?> article(NewsArticle newsArticle) async {
    var response = await http.get(Uri.parse('$homePage${newsArticle.url}'));
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));

      var article = document.getElementById("main-content-area");
      var thumbnailElement = article?.querySelector('img');
      var content = article?.querySelectorAll('.wysiwyg p')
          .map((e) => e.innerHtml)
          .join("<br><br>");
      var thumbnail = "$homePage${thumbnailElement?.attributes["src"]}";
      return newsArticle.fill(
        content: content,
        thumbnail: thumbnail,
      );
    }
    return null;
  }

  @override
  Future<Set<NewsArticle?>> articles({
    String category = "features",
    int page = 1,
  }) async {
    return super.articles(category: category, page: page);
  }

  @override
  Future<Set<NewsArticle?>> categoryArticles({
    String category = "/",
    int page = 1,
  }) async {
    Set<NewsArticle?> articles = {};

    if (category == "/") {
      category = "features";
    }

    var url = Uri.parse('https://www.aljazeera.com/graphql?wp-site=aje&operationName=ArchipelagoAjeSectionPostsQuery&variables={"category":"$category","categoryType":"where","postTypes":["blog","episode","opinion","post","video","external-article","gallery","podcast","longform","liveblog"],"quantity":10,"offset":14}&extensions={}');
    var headers = {'wp-site': 'aje'};

    var response = await http.get(url, headers: headers);
    if (json.decode(response.body)["data"]["articles"]==null) {
      url = Uri.parse('https://www.aljazeera.com/graphql?wp-site=aje&operationName=ArchipelagoAjeSectionPostsQuery&variables={"category":"$category","categoryType":"categories","postTypes":["blog","episode","opinion","post","video","external-article","gallery","podcast","longform","liveblog"],"quantity":10,"offset":14}&extensions={}');
      response = await http.get(url, headers: headers);
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      var articlesData = data["data"]["articles"];
      for (var element in articlesData) {
        var title = element['title'];
        var author = element['author'].isNotEmpty?element['author'][0]['name']:"";
        var thumbnail = element['featuredImage']['sourceUrl'];
        var time = element['date'];
        var articleUrl = element['link'];
        var excerpt = element['excerpt'];
        articles.add(NewsArticle(
          publisher: this,
          title: title ?? "",
          content: "",
          excerpt: excerpt,
          author: author ?? "",
          url: articleUrl,
          thumbnail: thumbnail ?? "",
          publishedAt: parseDateString(time?.trim() ?? ""),
        ));
      }
    }

    return articles;
  }

  @override
  Future<Set<NewsArticle?>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) async {
    return {};
  }
}