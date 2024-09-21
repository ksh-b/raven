import 'package:raven/model/article.dart';
import 'package:raven/model/category.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/time.dart';

class TheWire extends Publisher {
  @override
  String get name => "The Wire";

  @override
  String get homePage => "https://cms.thewire.in";

  @override
  Future<Map<String, String>> get categories => extractCategories();

  @override
  String get iconUrl =>
      "https://cdn.thewire.in/wp-content/uploads/2020/07/09150055/wirelogo_square_white_on_red_favicon.ico";

  @override
  String get mainCategory => Category.india.name;

  Future<Map<String, String>> extractCategories() async {
    return {
      "Politics": "/category/politics",
      "Economy": "/category/economy",
      "World": "/category/world",
      "Security": "/category/security",
      "Law": "/category/law",
      "Science": "/category/science",
      "Society": "/category/society",
      "Culture": "/category/culture",
    };
  }

  @override
  Future<Set<Article>> categoryArticles({
    String category = "All",
    int page = 1,
  }) async {
    if (category == '/') {
      category = 'home';
    }
    String apiUrl =
        'https://cms.thewire.in/wp-json/thewire/v2/posts$category/recent-stories/?page=$page&per_page=5';
    return extract(apiUrl, false, category);
  }

  @override
  Future<Set<Article>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) {
    String apiUrl = 'https://cms.thewire.in/wp-json/thewire/v2/posts/search';
    Map<String, String> params = {
      'keyword': searchQuery,
      'orderby': 'rel',
      'per_page': '5',
      'page': '$page',
      'type': 'opinion',
    };
    Uri uri = Uri.parse(apiUrl).replace(queryParameters: params);
    String fullUrl = uri.toString();
    return extract(fullUrl, true, searchQuery);
  }

  Future<Set<Article>> extract(
      String apiUrl, bool isSearch, String category) async {
    Set<Article> articles = {};
    var response = await dio().get(apiUrl);

    if (response.successful) {
      List data;
      if (isSearch) {
        data = (response.data)["generic"];
      } else {
        try {
          data = (response.data);
        } catch (e) {
          data = [];
        }
      }
      for (var element in data) {
        var title = element['post_title'];
        var author = element['post_author_name'][0]["author_name"];
        var thumbnail =
            element['hero_image'] == false ? "" : element['hero_image'][0];
        var time = element["post_date_gmt"];
        var articleUrl =
            '/wp-json/thewire/v2/posts/detail/${element['post_name']}';
        var excerpt = element['post_excerpt'];
        var tags = element['categories'].map((e) => e['name']).toList();
        articles.add(
          Article(
            publisher: name,
            title: title ?? "",
            content: "",
            excerpt: excerpt,
            author: author ?? "",
            url: articleUrl,
            thumbnail: thumbnail ?? "",
            category: category,
            publishedAt: stringToUnix(time),
            tags: List<String>.from(tags),
          ),
        );
      }
    }
    return articles;
  }

  @override
  Future<Article> article(Article newsArticle) async {
    Article newsArticle_ = newsArticle;
    var response = await dio().get('$homePage${newsArticle.url}');
    if (response.successful) {
      var data = (response.data);
      var postDetail = data["post-detail"][0];
      var content = postDetail["post_content"];
      var thumbnail = postDetail["featured_image"][0];
      newsArticle_ = newsArticle.fill(
        content: content,
        thumbnail: thumbnail,
      );
    }
    return newsArticle_;
  }

  @override
  Future<Set<Article>> articles({
    String category = "home",
    int page = 1,
  }) async {
    return super.articles(category: category, page: page);
  }

  @override
  bool get hasSearchSupport => true;
}
