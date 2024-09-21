import 'package:html/parser.dart' as html_parser;
import 'package:intl/intl.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/category.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/time.dart';

class TorrentFreak extends Publisher {
  @override
  String get name => "TorrentFreak";

  @override
  String get homePage => "https://torrentfreak.com";

  @override
  Future<Map<String, String>> get categories => extractCategories();

  @override
  String get mainCategory => Category.technology.name;

  Future<Map<String, String>> extractCategories() async {
    Map<String, String> map = {};
    var response = await dio().get(homePage);
    if (response.successful) {
      var document = html_parser.parse(response.data);
      document.querySelectorAll('.sub-menu a').forEach((element) {
        map.putIfAbsent(
          element.text,
          () => element.attributes["href"]!.replaceAll(homePage, ''),
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
      var articleElement = document.querySelector('.article__body');
      var excerptElement = document.querySelector('.article__excerpt');
      var thumbnailElement = document.querySelector('section[data-bg]');
      var content = articleElement?.innerHtml;
      var excerpt = excerptElement?.text;
      var thumbnail = thumbnailElement?.attributes["data-bg"];
      newsArticle = newsArticle.fill(
        content: content,
        excerpt: excerpt,
        thumbnail: thumbnail,
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

  Future<Set<Article>> extract(String url, String category) async {
    Set<Article> articles = {};
    var response = await dio().get(url);

    if (response.successful) {
      var document = html_parser.parse(response.data);

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
        var tags = articleUrlElement
                ?.querySelectorAll(".preview-article__category")
                .map((e) => e.text)
                .toList() ??
            [];

        if (time != null) {
          if (time.contains("today")) {
            time = DateTime.now().toIso8601String();
          } else if (time.contains("yesterday")) {
            time = DateTime.now().subtract(Duration(days: 1)).toIso8601String();
          } else {
            DateTime parsedDateTime =
                DateFormat("MMMM d, y, HH:mm").parse(time);
            time = DateFormat("yyyy-MM-dd HH:mm:ss").format(parsedDateTime);
          }
        }

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
            tags: tags,
            category: category,
          ),
        );
      }
    }
    return articles;
  }

  @override
  Future<Set<Article>> categoryArticles({
    String category = "/",
    int page = 1,
  }) {
    String categoryPath =
        category.isNotEmpty && category != "/" ? "/category/$category" : "";
    var url = '$homePage$categoryPath/page/$page';
    return extract(url, category);
  }

  @override
  Future<Set<Article>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) {
    return extract("$homePage/page/$page/?s=$searchQuery", searchQuery);
  }

  @override
  bool get hasSearchSupport => true;
}
