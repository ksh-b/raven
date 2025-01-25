import 'package:raven/model/article.dart';
import 'package:raven/model/source/source_dart.dart';
import 'package:raven/model/source/sources_json.dart';
import 'package:raven/provider/extractor/css.dart';
import 'package:raven/provider/extractor/json.dart';
import 'package:raven/repository/git/github.dart';
import 'package:raven/repository/news/custom/json.dart';

class FeedExtractor {

  Future<Set<Article>> extractSearchArticles(
    JsonSource source,
    String query,
  ) async {
    List<Article> articleList = [];
    SourceArticle? searchArticles = source.externalSource?.searchArticles;
    if (searchArticles?.extractor == "css") {
      articleList = await extractSearchArticlesCss(source, query, 1);
    } else if (searchArticles?.extractor == "json") {
      articleList = await extractSearchArticlesJson(source, query, 1);
    }
    return articleList.toSet();
  }

  Future<Article> extractArticleContent(
    JsonSource source,
    Article article,
  ) async {
    if (source.externalSource?.article.extractor == "css") {
      article = (await extractArticleCss(source, article));
    } else if (source.externalSource?.article.extractor == "json") {
      article = (await extractArticleJson(source, article));
    }
    return article;
  }

  Future<Map<String, String>> extractCategories(JsonSource source) async {
    Map<String, String> categories = {};
    var extractor = source.externalSource?.categories.extractor;
    if (extractor == "css") {
      categories = await extractCategoriesCss(source);
    } else if (extractor == "json") {
      categories = await extractCategoriesJson(source);
    }
    return categories;
  }

  Future<Set<Article>> extractCategoryArticles(
    JsonSource source,
    String category,
  ) async {
    List<Article> articleList = [];
    if (source.externalSource?.categoryArticles.extractor == "css") {
      articleList = await extractCategoryArticlesCss(
        source,
        category,
        1,
      );
    } else if (source.externalSource?.categoryArticles.extractor == "json") {
      articleList = await extractCategoryArticlesJson(
        source,
        category,
        1,
      );
    }
    return articleList.toSet();
  }
}
