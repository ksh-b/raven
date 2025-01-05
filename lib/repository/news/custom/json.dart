import 'package:hive/hive.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/model/source/source_dart.dart';
import 'package:raven/provider/feed_extractor.dart';

part 'json.g.dart';

@HiveType(typeId: 14)
class JsonSource extends Source {
  JsonSource({
    required super.id,
    required super.name,
    required super.homePage,
    required super.hasSearchSupport,
    required super.hasCustomSupport,
    required super.iconUrl,
    required super.siteCategories,
    required super.externalSource,
  });

  @override
  Future<Set<Article>> categoryArticles({
    String category = "",
    int page = 1,
  }) async {
    return FeedExtractor().extractCategoryArticles(this, category);
  }

  @override
  Future<Set<Article>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) async {
    return FeedExtractor().extractSearchArticles(this, searchQuery);
  }

  @override
  Future<Article> article(Article article) async {
    return FeedExtractor().extractArticleContent(this, article);
  }

  @override
  Future<Map<String, String>> categories() async {
    return FeedExtractor().extractCategories(this);
  }

}
