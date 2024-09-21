import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/model/article.dart';
import 'package:raven/model/category.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/string.dart';
import 'package:raven/utils/time.dart';

class Reuters extends Publisher {
  @override
  String get name => "Reuters";

  @override
  String get homePage => "https://www.reuters.com";

  @override
  Future<Map<String, String>> get categories => extractCategories();

  @override
  String get mainCategory => Category.world.name;

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
  Future<Article> article(Article article) async {
    var headers_ = await dio().get(
      "https://www.reuters.com/",
      options: Options(
        responseType: ResponseType.plain,
        validateStatus: (status) => true,
      ),
    ).then((value) => value.headers.map);

    await dio().get(
      "https://www.reuters.com${article.url}",
      options: Options(
        headers: {"Cookie": headers_['set-cookie']},
        validateStatus: (status) => true,
      ),
    ).then((response) {
      if (response.statusCode == 200) {
        var document = html_parser.parse(response.data);
        var content = document.querySelector("div[class*=article-body]")?.outerHtml;
        article = article.fill(
          content: content,
          thumbnail: "",
        );
      }
    });

    return article;
  }

  @override
  Future<Set<Article>> articles({
    String category = "world",
    int page = 1,
  }) async {
    return super.articles(category: category, page: page);
  }

  Future<Set<Article>> extract(String apiUrl, String category) async {
    Set<Article> articles = {};

    List articlesData = [];
    await dio().get(apiUrl).then((response) {
      if (response.statusCode == 200) {
        final data = response.data;
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
          var tags = element['kicker']['names'];
          articles.add(
            Article(
              publisher: name,
              title: title ?? "",
              content: "",
              excerpt: excerpt,
              author: author ?? "",
              url: articleUrl,
              thumbnail: thumbnail ?? "",
              publishedAt: stringToUnix(time?.trim() ?? ""),
              tags: List<String>.from(tags),
              category: category,
            ),
          );
        }
      }
    });
    return articles;
  }

  @override
  Future<Set<Article>> categoryArticles({
    String category = "All",
    int page = 1,
  }) {
    if (category == "/") {
      category = "world";
    }
    String apiUrl =
        '$homePage/pf/api/v3/content/fetch/recent-stories-by-sections-v1?'
        'query={"section_ids":"/$category/","offset": ${(page - 1) * 5},'
        '"size":5,'
        '"website":"reuters"}';

    return extract(apiUrl, category);
  }

  @override
  Future<Set<Article>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) {
    searchQuery = getAsSearchQuery(searchQuery);
    String apiUrl =
        'https://www.reuters.com/pf/api/v3/content/fetch/articles-by-search-v2?'
        'query={"keyword":"$searchQuery","offset":${(page - 1) * 5},'
        '"orderby":"display_date:desc","size":5,"website":"reuters"}'
        '&_website=reuters';

    return extract(apiUrl, searchQuery);
  }

  @override
  bool get hasSearchSupport => true;
}
