import 'package:raven/model/article.dart';
import 'package:raven/service/html_content_extractor.dart';
import 'package:raven/service/smort.dart';

class FallbackProvider {
  Future<NewsArticle> get(NewsArticle article) async {
      var maybeArticle = await HtmlContentExtractor().fallback(article);
      if (!maybeArticle.key) {
        maybeArticle = await Smort().fallback(article);
      }
      if (!maybeArticle.key) {
        return article;
      }
      return maybeArticle.value;
  }
}
