import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/brain/dio_manager.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/utils/time.dart';

class BleepingComputer extends Publisher {
  @override
  String get homePage => "https://www.bleepingcomputer.com";

  @override
  String get name => "BleepingComputer";

  @override
  Category get mainCategory => Category.technology;

  @override
  Future<NewsArticle> article(NewsArticle newsArticle) async {
    await dio().get("$homePage${newsArticle.url}").then((response) {
      if (response.statusCode == 200) {
        Document document = html_parser.parse(response.data);
        String? thumbnail = "";
        String? content = document
            .querySelectorAll(".articleBody > :not(.cz-related-article-wrapp)")
            .toList()
            .map((e) => e.innerHtml)
            .join("<br><br>");
        newsArticle = newsArticle.fill(
          content: content,
          thumbnail: thumbnail,
        );
      }
    });

    return newsArticle;
  }

  @override
  bool get hasSearchSupport => false;

  @override
  Future<Map<String, String>> get categories async => {};

  @override
  Future<Set<NewsArticle>> categoryArticles(
      {String category = "", int page = 1}) async {
    Set<NewsArticle> articles = {};
    await dio()
        .get(page != 1 ? "$homePage/news/page/$page" : "$homePage/news/")
        .then(
      (response) {
        if (response.statusCode == 200) {
          Document document = html_parser.parse(response.data);
          List<Element> articleElements =
              document.querySelectorAll("#bc-home-news-main-wrap > li");
          for (Element articleElement in articleElements) {
            String? title = articleElement.querySelector("h4")?.text;
            String? excerpt = articleElement.querySelector("p")?.text;
            String? author = articleElement.querySelector(".author")?.text;
            String? url =
                articleElement.querySelector("h4 a")?.attributes["href"];
            var tags = articleElement
                .querySelectorAll(".bc_latest_news_category span a")
                .map((e) => e.text)
                .toList();
            String? thumbnail = articleElement
                .querySelector(".bc_latest_news_img img")
                ?.attributes["src"];
            if (thumbnail != null && thumbnail.endsWith("==")) {
              thumbnail = articleElement
                  .querySelector(".bc_latest_news_img img")
                  ?.attributes["data-src"];
            }
            String? content = "";
            String? date = articleElement.querySelector(".bc_news_date")?.text;
            String? time = articleElement.querySelector(".bc_news_time")?.text;
            int parsedTime = stringToUnix(
              "$date $time",
              format: "MMMM dd, yyyy hh:mm a",
            );

            articles.add(
              NewsArticle(
                publisher: name,
                title: title ?? "",
                content: content,
                excerpt: excerpt ?? "",
                author: author ?? "",
                url: url?.replaceFirst(homePage, "") ?? "",
                thumbnail: thumbnail ?? "",
                publishedAt: parsedTime,
                tags: tags,
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
  Future<Set<NewsArticle>> searchedArticles(
      {required String searchQuery, int page = 1}) async {
    return {};
  }
}
