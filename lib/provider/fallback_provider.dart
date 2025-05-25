import 'package:klaws/model/article.dart';
import 'package:klaws/provider/feed_extractor.dart';
import 'package:raven/repository/publishers.dart';
import 'package:raven/service/http_client.dart';

class FallbackProvider {
  Future<Article> get(Article article) async {
    if (!article.url.contains(publishers()[article.source.id]!.homePage)) {
      var homePage = publishers()[article.source.id]!.homePage;
      article.url = homePage + article.url;
    }
    return FeedExtractor().extractArticleContent(article.source, article, dio());
  }
}
