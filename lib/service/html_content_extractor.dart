import 'package:html/parser.dart' as html_parser;
import 'package:raven/brain/dio_manager.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/fallback.dart';
import 'package:raven/utils/html_helper.dart';

class HtmlContentExtractor extends Fallback {
  @override
  String get name => "Local";

  @override
  Future<MapEntry<bool, NewsArticle>> fallback(NewsArticle article) async {
    String articleBody = "";
    await dio().get(article.url).then((response) {
      var document = html_parser.parse(response.data);
      articleBody = [
        document.querySelector("article")?.innerHtml ?? "",
        document.querySelector("*[class*='article-body']")?.innerHtml ?? "",
        document.querySelector("*[class*='article']")?.innerHtml ?? "",
        document.querySelector("*[class*='story']")?.innerHtml ?? "",
        article.content
      ].reduce((o1, o2) => o1.length > o2.length ? o1 : o2);
    },);
    if (articleBody.isEmpty || articleBody == article.content) {
      return MapEntry(false, article);
    }
    article.content = cleanHtml(articleBody).join();
    return MapEntry(true, article);
  }
}
