import 'package:html/parser.dart' as html_parser;
import 'package:raven/model/article.dart';
import 'package:raven/model/category.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/time.dart';

class TheVerge extends Publisher {
  @override
  String get name => "The Verge";

  @override
  String get homePage => "https://www.theverge.com";

  @override
  Future<Map<String, String>> get categories => extractCategories();

  @override
  String get mainCategory => Category.technology.name;

  Future<Map<String, String>> extractCategories() async {
    Map<String, String> map = {};
    var response = await dio().get(homePage);

    if (response.successful) {
      var document = html_parser.parse(response.data);

      document
          .querySelectorAll('.duet--navigation--navigation li a[class]')
          .forEach((element) {
        map.putIfAbsent(
          element.text,
          () => element.attributes["href"]!,
        );
      });
    }

    return map;
  }

  @override
  Future<Article> article(Article newsArticle) async {
    var response = await dio().get('$homePage${newsArticle.url}');
    if (response.successful) {
      var document = html_parser.parse(response.data);
      var articleElement = document.querySelector(
              '.duet--article--article-body-component-container') ??
          document.querySelector(".flex-1");
      var authorElement = document.querySelector('span.font-medium > a') ??
          document.querySelector("a[href*=authors]");
      var thumbnailElement =
          document.querySelector('.duet--article--lede-image img');
      var timeElement = document.querySelector('time');
      var content = articleElement?.innerHtml;
      var author = authorElement?.text;
      var thumbnail =
          thumbnailElement != null ? thumbnailElement.attributes["src"] : "";
      var time = timeElement?.attributes["datetime"];
      newsArticle = newsArticle.fill(
        content: content,
        author: author,
        thumbnail: thumbnail,
        publishedAt: stringToUnix(time?.trim() ?? ""),
      );
    }
    return newsArticle;
  }

  @override
  Future<Set<Article>> articles({
    String category = "",
    int page = 1,
  }) async {
    return super.articles(category: category, page: page);
  }

  Future<Set<Article>> extractCategoryArticles(
      String url, String category) async {
    Set<Article> articles = {};
    var response = await dio().get(url);

    if (response.successful) {
      var document = html_parser.parse(response.data);

      var articleElements =
          document.querySelectorAll('.duet--content-cards--content-card');
      for (var element in articleElements) {
        var titleElement =
            element.querySelector('h2') ?? element.querySelector(".inline");
        var authorElement = element.querySelector('a[href*=authors]');
        var thumbnailElement = element.querySelector('img');
        var articleUrlElement =
            element.querySelector('h2 a') ?? element.querySelector('a');
        var timeElement = element.querySelector('time');
        var title = titleElement?.text;
        var author = authorElement?.text;
        var thumbnail = thumbnailElement?.attributes["src"];
        var time = timeElement?.attributes["datetime"];
        var articleUrl = articleUrlElement?.attributes["href"];
        articles.add(
          Article(
            publisher: name,
            title: title ?? "",
            content: "",
            excerpt: "",
            author: author ?? "",
            url: articleUrl?.replaceFirst(homePage, "") ?? "",
            thumbnail: thumbnail ?? "",
            publishedAt: stringToUnix(time?.trim() ?? ""),
            category: category,
            tags: [],
          ),
        );
      }
    }

    return articles;
  }

  Future<Set<Article>> extractSearchArticles(
      String searchQuery, int page) async {
    Set<Article> articles = {};
    var response =
        await dio().get('$homePage/api/search?q=$searchQuery&page=${page - 1}');

    if (response.successful) {
      var document = (response.data);

      var articleElements = document["items"];
      for (var element in articleElements) {
        var title = element["title"];
        var url = element["link"];
        var excerpt = element["htmlSnippet"];
        var thumbnail = element["pagemap"]["cse_image"][0]["src"];
        var time = element["snippet"].split("...")[0];
        var dateEntry = stringToUnix(time, format: 'MMM d, yyyy');
        articles.add(
          Article(
            publisher: name,
            title: title ?? "",
            content: "",
            excerpt: excerpt,
            author: "",
            url: url.replaceFirst(homePage, ""),
            thumbnail: thumbnail,
            publishedAt: dateEntry,
            category: searchQuery,
            tags: [],
          ),
        );
      }
    }
    return articles;
  }

  @override
  Future<Set<Article>> categoryArticles({
    String category = "All",
    int page = 1,
  }) {
    String categoryPath =
        category.isNotEmpty ? "/$category/archives" : "/archives";
    var url = '$homePage$categoryPath/$page';
    return extractCategoryArticles(url, category);
  }

  @override
  Future<Set<Article>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) {
    return extractSearchArticles(searchQuery, page);
  }

  @override
  bool get hasSearchSupport => true;
}
