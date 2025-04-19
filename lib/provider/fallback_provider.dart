import 'package:klaws/model/article.dart';
import 'package:raven/repository/publishers.dart';
import 'package:readability/readability.dart' as readability;

class FallbackProvider {
  Future<Article> get(Article article) async {
    if (!article.url.contains(publishers()[article.source.id]!.homePage)) {
      var homePage = publishers()[article.source.id]!.homePage;
      article.url = homePage + article.url;
    }

    var fullArticle = await readability.parseAsync(article.url);
    return Article(
      source: article.source,
      sourceName: article.sourceName,
      title: fullArticle.title ?? article.title,
      content: fullArticle.content ?? article.content,
      excerpt: fullArticle.excerpt ?? article.excerpt,
      author: fullArticle.author ?? article.author,
      url: article.url,
      thumbnail: fullArticle.imageUrl ?? article.thumbnail,
      category: article.category,
      tags: article.tags,
      publishedAt: article.publishedAt,
      publishedAtString: fullArticle.publishedTime ?? article.publishedAtString,
    );
  }
}
