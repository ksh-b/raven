import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/model/article.dart';
import 'package:raven/model/category.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/network.dart';

class TheQuint extends Publisher {
  @override
  String get name => "The Quint";

  @override
  String get homePage => "https://www.thequint.com";

  @override
  Future<Map<String, String>> get categories => extractCategories();

  @override
  String get mainCategory => Category.india.name;

  @override
  bool get hasSearchSupport => true;

  Future<Map<String, String>> extractCategories() async {
    Map<String, String> map = {};
    var response = await dio().get(homePage);
    if (response.successful) {
      var document = html_parser.parse(response.data);
      document
          .querySelectorAll('#second-nav-bar a[id*=ga4-header]')
          .forEach((element) {
        map.putIfAbsent(
          element.text,
          () {
            return element.attributes["href"]!.replaceFirst("news", "");
          },
        );
      });
    }

    var unsupported = ["Videos", "The Quint Lab", "Graphic Novels"];
    return map..removeWhere((key, value) => unsupported.contains(key));
  }

  @override
  Future<Article> article(Article newsArticle) async {
    var response = await dio().get(newsArticle.url);
    if (response.successful) {
      Document document = html_parser.parse(response.data);
      var content =
          document.querySelectorAll(".story-element-text p,blockquote");
      newsArticle = newsArticle.fill(
        content: content.map((e) => e.innerHtml).join("<br><br>"),
      );
    }
    return newsArticle;
  }

  @override
  Future<Set<Article>> categoryArticles({
    String category = "/",
    int page = 1,
  }) async {
    Set<Article> articles = {};
    var limit = 5;
    var offset = limit * (page - 1);
    if (category == "/") {
      category = "india";
    }
    String url =
        "$homePage/api/v1/collections$category?limit=$limit&offset=$offset";
    var response = await dio().get(url);

    if (response.successful) {
      List data = (response.data)["items"];

      for (var element in data) {
        if (element["story"] == null) continue;
        List<String> tags = [];
        var title = element["story"]['headline'];
        var author = element['story']["author-name"];
        var thumbnail =
            "https://images.thequint.com/${element['story']['hero-image-s3-key']}";
        var time = element['story']["last-published-at"];
        String articleUrl = "${element['story']["url"]}";
        var excerpt = element['story']['summary'] ?? "";
        var sections = element['story']["sections"];
        for (var section in sections) {
          tags.add(section["name"]);
        }
        articles.add(
          Article(
            publisher: name,
            title: title ?? "",
            content: "",
            excerpt: excerpt,
            author: author ?? "",
            url: articleUrl,
            tags: tags,
            thumbnail: thumbnail,
            publishedAt: time,
            category: category,
          ),
        );
      }
    }
    return articles;
  }

  @override
  Future<Set<Article>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) async {
    Set<Article> articles = {};
    String apiUrl = '$homePage/route-data.json?path=/search&q=$searchQuery';
    var response = await dio().get(apiUrl);
    if (response.successful) {
      List data = (response.data)["data"]["stories"];

      for (var element in data) {
        List<String> tags = [];
        var title = element['headline'];
        var author = element['authors'][0]["name"];
        var thumbnail =
            "https://images.thequint.com/${element['hero-image-s3-key']}";
        var time = element["last-published-at"];
        var articleUrl = element["url"];
        var sections = element["sections"];
        for (var section in sections) {
          tags.add(section["name"]);
        }
        articles.add(
          Article(
            publisher: name,
            title: title ?? "",
            content: "",
            excerpt: "",
            author: author ?? "",
            url: articleUrl,
            thumbnail: thumbnail,
            publishedAt: time,
            category: "",
            tags: tags,
          ),
        );
      }
    }

    return articles;
  }
}
