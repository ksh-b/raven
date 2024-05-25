import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/brain/dio_manager.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/utils/time.dart';

class TheHindu extends Publisher {
  @override
  String get name => "The Hindu";

  @override
  String get homePage => "https://www.thehindu.com";

  @override
  Future<Map<String, String>> get categories => extractCategories();

  @override
  Category get mainCategory => Category.india;

  @override
  bool get hasSearchSupport => false;

  Future<Map<String, String>> extractCategories() async {
    Map<String, String> map = {};
    await dio().get(homePage).then((response) {
      if (response.statusCode == 200) {
        var document = html_parser.parse(response.data);
        document
            .querySelectorAll(".header-menu .nav-link")
            .sublist(1)
            .forEach((element) {
          map.putIfAbsent(
            element.text.trim(),
            () {
              return element.attributes["href"]!.replaceFirst(homePage, "");
            },
          );
        });
      }
    });

    return map..removeWhere((key, value) => key == "e-Paper");
  }

  @override
  Future<NewsArticle> article(NewsArticle newsArticle) async {
    await dio().get("$homePage${newsArticle.url}").then(
      (response) {
        if (response.statusCode == 200) {
          Document document = html_parser.parse(response.data);
          var isLive = document.querySelector(".live-span") != null;
          var content = [];
          if (isLive) {
            content.add(document.querySelector("div[itemprop='articleBody']"));
            content.add(document.querySelector("#liveentryListskeyevent"));
            content.add(document.querySelector(".article-live-blocker"));
          } else {
            content = document.querySelectorAll("div[itemprop='articleBody']");
          }
          var related =
              document.querySelector(".related-topics")?.innerHtml ?? "";
          var thumbnail = document
              .querySelector("meta property='og:image'")
              ?.attributes["content"];
          var excerpt = document.querySelector(".sub-title")?.text;
          var timestamp = document
              .querySelector(".publish-time")
              ?.text
              .split(" | ")[0]
              .trim();
          var tags = document
              .querySelectorAll(".breadcrumb li a[itemprop=item]")
              .sublist(1)
              .map((e) => e.text)
              .toList();
          newsArticle = newsArticle.fill(
              content: content
                  .map(
                    (e) => e.innerHtml,
                  )
                  .join()
                  .replaceFirst(related, "")
                  .trim(),
              thumbnail: thumbnail,
              excerpt: excerpt,
              publishedAt:
                  stringToUnix(timestamp ?? "", format: "MMMM d, yyyy hh:mm a"),
              tags: tags);
        }
      },
    );

    return newsArticle;
  }

  @override
  Future<Set<NewsArticle>> categoryArticles({
    String category = "/",
    int page = 1,
  }) async {
    Set<NewsArticle> articles = {};
    if (category == "/") {
      category = "/news/";
    }
    String url = "$homePage$category/fragment/showmoredesked?page=$page";
    await dio().get(url).then(
      (response) {
        if (response.statusCode == 200) {
          Document document = html_parser.parse(response.data);
          var articleElements = [];
          articleElements = document.querySelectorAll(".result .element");
          if (articleElements.isEmpty) {
            articleElements = document.querySelectorAll(".element");
          }
          for (var article in articleElements) {
            List<String> tags = [];
            var title = article.querySelector(".title a")?.text.trim();
            var articleUrl =
                article.querySelector(".title a")?.attributes["href"] ?? "";
            var author = article.querySelector(".author-name")?.text;
            var thumbnail = article
                .querySelector(".picture img")
                ?.attributes["data-original"]
                .replaceFirst("SQUARE_80", "LANDSCAPE_1200");
            var excerpt = article.querySelector(".sub-text")?.text;
            title = title
                .replaceFirst("Morning Digest | ", "")
                .replaceFirst("Top news of the day: ", "");
            articles.add(NewsArticle(
                publisher: name,
                title: title ?? "",
                content: "",
                excerpt: excerpt ?? "",
                author: author ?? "",
                url: articleUrl.replaceFirst(homePage, ""),
                tags: tags,
                thumbnail: thumbnail ?? "",
                publishedAt: -1,
                category: category));
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
    return {};
  }
}
