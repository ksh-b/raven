import 'package:raven/model/article.dart';
import 'package:raven/model/category.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/network.dart';

class ProthamAlo extends Publisher {
  @override
  String get name => "প্রথম আলো";

  @override
  String get homePage => "https://www.prothomalo.com";

  @override
  Future<Map<String, String>> get categories => extractCategories();

  @override
  String get mainCategory => Category.bangladesh.name;

  @override
  bool get hasSearchSupport => true;

  Future<Map<String, String>> extractCategories() async {
    return {
      "সর্বশেষ": "/latest",
      "রাজনীতি": "/politics",
      "বাংলাদেশ": "/bangladesh",
      "অপরাধ": "/crime-bangladesh",
      "বিশ্ব": "/world-all",
      "বাণিজ্য": "/business-all",
      "মতামত": "/opinion-all",
      "খেলা": "/sports-all",
      "বিনোদন": "/entertainment-all",
      "জীবনযাপন": "/lifestyle-all",
    };
  }

  @override
  Future<Set<Article>> categoryArticles({
    required String category,
    int page = 1,
  }) async {
    Set<Article> articles = {};
    var limit = 10;
    var offset = limit * (page - 1);
    String apiUrl =
        "$homePage/api/v1/collections$category?offset=$offset&limit=$limit";
    var response = await dio().get(apiUrl);
    if (response.successful) {
      var articlesData = response.data;
      var data = articlesData["items"];
      for (var element in data) {
        if(!element.containsKey('item')) {
          continue;
        }
        var title = element['item']['headline'][0];
        var author = element['story']["author-name"];
        var thumbnail = element['story']["hero-image-s3-key"] ??
            element['story']["alternative"]["home"]["default"]["hero-image"]
                ["hero-image-s3-key"] ??
            "";
        var time = element['story']["published-at"];
        var articleUrl = element['story']['slug'];
        var excerpt = element['story']['summary'];
        var tags = element['story']['sections'].map((e) => e['name']).toList();
        articles.add(
          Article(
            publisher: name,
            title: title ?? "",
            content: "",
            excerpt: excerpt ?? "",
            author: author ?? "",
            url: articleUrl,
            thumbnail: thumbnail ?? "",
            category: category,
            publishedAt: time,
            tags: List<String>.from(tags),
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
    var limit = 10;
    var offset = limit * (page - 1);
    String apiUrl =
        "$homePage/route-data.json?path=/search&q=$searchQuery&offset=$offset&limit=$limit";
    var response = await dio().get(apiUrl);

    if (response.successful) {
      var articlesData = response.data;
      var data = articlesData["data"]["stories"];
      for (var element in data) {
        var title = element['headline'][0];
        var author = element["author-name"];
        var thumbnail = element["hero-image-s3-key"] ?? "";
        var time = element["published-at"];
        var articleUrl = element['slug'];
        var excerpt = element['summary'];
        var tags = element['sections'].map((e) => e['name']).toList();
        articles.add(
          Article(
            publisher: name,
            title: title ?? "",
            content: "",
            excerpt: excerpt ?? "",
            author: author ?? "",
            url: articleUrl,
            thumbnail: thumbnail ?? "",
            category: searchQuery,
            publishedAt: time,
            tags: List<String>.from(tags),
          ),
        );
      }
    }

    return articles;
  }

  @override
  Future<Article> article(Article newsArticle) async {
    var response =
        await dio().get('$homePage/route-data.json?path=${newsArticle.url}');
    if (response.successful) {
      var data = (response.data);
      var content = "";
      var cards = data["data"]["story"]["cards"];
      for (var card in cards) {
        if (card["story-elements"][0]["type"] == "text") {
          content += card["story-elements"][0]["text"];
        } else if (card["story-elements"][0]["type"] == "image") {
          var image = card["story-elements"][0]["image-s3-key"];
          content += "<p><img src='$image'/></p>";
        }
      }
      newsArticle.content = content;
    }
    return newsArticle;
  }
}
