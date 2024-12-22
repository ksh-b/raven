import 'package:raven/model/article.dart';
import 'package:raven/repository/publishers.dart';
import 'package:raven/service/html_content_extractor.dart';

class FallbackProvider {
  Future<Article> get(Article article) async {
    if (!article.url.contains(publishers[article.source.id]!.homePage)) {
      var homePage = publishers[article.source.id]!.homePage;
      article.url = homePage + article.url;
    }

    var maybeArticle = await HtmlContentExtractor().fallback(article);
    if (!maybeArticle.key) {
      return article;
    }
    return maybeArticle.value;
  }
}
