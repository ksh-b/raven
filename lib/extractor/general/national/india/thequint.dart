import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/brain/dio_manager.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';

class TheQuint extends Publisher {
  @override
  String get name => "The Quint";

  @override
  String get homePage => "https://www.thequint.com";

  @override
  Future<Map<String, String>> get categories => extractCategories();

  @override
  Category get mainCategory => Category.india;

  Future<Map<String, String>> extractCategories() async {
    Map<String, String> map = {};
    await dio().get(homePage).then((response) {
      if (response.statusCode == 200) {
        var document = html_parser.parse(response.data);
        document
            .querySelectorAll('#second-nav-bar a[id*=ga4-header]')
            .forEach((element) {
          map.putIfAbsent(
            element.text,
            () {
              return element.attributes["href"]!
                  .replaceFirst("/", "")
                  .replaceFirst("news/", "");
            },
          );
        });
      }
    });

    var unsupported = ["Videos", "The Quint Lab", "Graphic Novels"];
    return map..removeWhere((key, value) => unsupported.contains(key));
  }

  @override
  Future<NewsArticle> article(NewsArticle newsArticle) async {
    await dio().get("$homePage${newsArticle.url}").then((response) {
      if (response.statusCode == 200) {
        Document document = html_parser.parse(response.data);
        var content =
        document.querySelectorAll(".story-element-text p,blockquote");
        newsArticle = newsArticle.fill(
          content: content.map((e) => e.innerHtml).join("<br><br>"),
        );
      }
    });
    return newsArticle;
  }

  @override
  Future<Set<NewsArticle>> categoryArticles({
    String category = "/",
    int page = 1,
  }) async {
    Set<NewsArticle> articles = {};
    var limit = 5;
    var offset = limit * (page - 1);
    if (category == "/") {
      category = "india";
    }
    String url =
        "$homePage/api/v1/collections/$category?limit=$limit&offset=$offset";

    await dio().get(url).then((response) {

      if (response.statusCode == 200) {
        List data = (response.data)["items"];

        for (var element in data) {
          if (element["story"] == null) continue;
          List<String> tags = [];
          var title = element["story"]['headline'];
          var author = element['story']["author-name"];
          var thumbnail =
              "https://images.thequint.com/${element['story']['hero-image-s3-key']}";
          var time = element['story']["last-published-at"];
          String articleUrl = element['story']["url"] ?? "";
          var excerpt = element['story']['summary'] ?? "";
          var sections = element['story']["sections"];
          for (var section in sections) {
            tags.add(section["name"]);
          }
          articles.add(NewsArticle(
              publisher: name,
              title: title ?? "",
              content: "",
              excerpt: excerpt,
              author: author ?? "",
              url: articleUrl.replaceFirst(homePage, ""),
              tags: tags,
              thumbnail: thumbnail,
              publishedAt: time,
              category: category));
        }
      }
    },);
    return articles;
  }

  @override
  Future<Set<NewsArticle>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) async {
    Set<NewsArticle> articles = {};
    String apiUrl = '$homePage/route-data.json?path=/search&q=$searchQuery';
    await dio().get(apiUrl).then((response) {
      if (response.statusCode == 200) {
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
          articles.add(NewsArticle(
              publisher: name,
              title: title ?? "",
              content: "",
              excerpt: "",
              author: author ?? "",
              url: articleUrl.replaceFirst(homePage, ""),
              thumbnail: thumbnail,
              publishedAt: time,
              category: searchQuery,
              tags: tags));
        }
      }
    });

    return articles;
  }
}
