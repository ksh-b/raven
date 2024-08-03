import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/brain/dio_manager.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/utils/time.dart';

class RfaCantonese extends Publisher {
  @override
  String get name => "RFA 自由亞洲電台粵語部";

  @override
  String get homePage => "https://www.rfa.org/cantonese";

  @override
  Future<Map<String, String>> get categories async {
    Map<String, String> map = {"Cantonese": "cantonese"};
    await dio().get(homePage, options: options).then(
          (response) {
        if (response.statusCode == 200) {
          var document = html_parser.parse(response.data);
          var elements = document.querySelectorAll("*[class*='nav-'] a");
          for (var element in elements) {
            if(element.attributes["href"]==homePage) {
              continue;
            }
            map.putIfAbsent(
              element.text,
                  () {
                return element.attributes["href"]!.replaceAll("$homePage/", "");
              },
            );
          }
        }
      },
    );
    return map..removeWhere((key, value) => ["video", "audio", "send_news_form"].contains(value) || value.contains("about/"),);
  }

  @override
  Category get mainCategory => Category.world;

  @override
  bool get hasSearchSupport => true;

  Options options = Options(headers: {
    "User-Agent":
    "Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30",
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate, br",
    "Connection": "keep-alive",
  });

  @override
  Future<NewsArticle> article(NewsArticle newsArticle) async {
    await dio().get(newsArticle.url, options: options).then((response) {
      if (response.statusCode == 200) {
        var document = html_parser.parse(response.data);
        var content = document.querySelector('#storytext')?.text ?? "";
        var author = document.querySelector("#story_byline")?.text ?? "";
        var thumbnail = document.querySelector("#headerimg img")?.text ?? "";

        newsArticle = newsArticle.fill(
          content: content,
          author: author,
          tags: [],
          thumbnail: thumbnail,
        );
      }
    });

    return newsArticle;
  }

  @override
  Future<Set<NewsArticle>> categoryArticles({
    String category = "news",
    int page = 1,
  }) async {
    Set<NewsArticle> articles = {};
    var limit = 15;
    var offset = (page - 1) * limit;

    await dio().get(
      "$homePage/$category/story_archive?b_start:int=$offset",
      options: options,
    )
        .then(
          (response) {
        if (response.statusCode == 200) {
          var document = html_parser.parse(response.data);
          var data = document.querySelectorAll(".sectionteaser");
          for (var article in data) {
            var title = article.querySelector("span")?.text ?? "";
            var thumbnail =
                article.querySelector("img")?.attributes["src"] ?? "";
            var publishedAt = article.querySelector(".story_date")?.text ?? "";
            var excerpt =
                article.querySelector("story_description")?.text ?? "";
            var url = article.querySelector("a")?.attributes["href"] ?? "";

            articles.add(
              NewsArticle(
                publisher: name,
                title: title,
                content: "",
                excerpt: excerpt,
                author: "",
                url: url,
                tags: [],
                thumbnail: thumbnail,
                publishedAt: stringToUnix(publishedAt, format: "yyyy-MM-dd"),
                category: category,
              ),
            );
          }
        }
      },
    );

    return articles;
  }

  @override
  Future<Set<NewsArticle>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) async {
    Set<NewsArticle> articles = {};
    var limit = 30;
    var offset = (page - 1) * limit;
    await dio()
        .get(
        "$homePage/@@search?SearchableText=$searchQuery&sort_on=Date&b_start:int=$offset",
        options: options)
        .then(
          (response) {
        if (response.statusCode == 200) {
          var document = html_parser.parse(response.data);
          var data = document.querySelectorAll(".searchresult");
          for (var article in data) {
            var title = article.querySelector("a.state-published")?.text ?? "";
            var thumbnail =
                article.querySelector("img")?.attributes["src"] ?? "";
            var publishedAt =
                article.querySelector(".searchresultdate")?.text.trim() ?? "";
            var excerpt =
                article.querySelector(".croppedDescription")?.text ?? "";
            var url = article
                .querySelector("a.state-published")
                ?.attributes["href"] ??
                "";

            articles.add(
              NewsArticle(
                publisher: name,
                title: title,
                content: "",
                excerpt: excerpt,
                author: "",
                url: url,
                tags: [],
                thumbnail: thumbnail,
                publishedAt: stringToUnix(publishedAt, format: "yyyy-MM-dd"),
                category: searchQuery,
              ),
            );
          }
        }
      },
    );

    return articles;
  }
}
