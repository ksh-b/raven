
import 'package:hive/hive.dart';

part 'source_dart.g.dart';

@HiveType(typeId: 5)
class ExternalSource {

  @HiveField(0)
  String name = "";
  @HiveField(1)
  String homePage = "";
  @HiveField(2)
  List<String> category = [];
  @HiveField(3)
  Categories categories = Categories.empty();
  @HiveField(4)
  String categoryUrl = "";
  @HiveField(5)
  String iconUrl = "";
  @HiveField(6)
  bool supportsCustomCategory = false;
  @HiveField(7)
  SourceArticle categoryArticles = SourceArticle.empty();
  @HiveField(8)
  SourceArticle article = SourceArticle.empty();
  @HiveField(9)
  String searchUrl = "";
  @HiveField(10)
  SourceArticle searchArticles = SourceArticle.empty();
  @HiveField(11)
  Headers headers = Headers.fromJson({});
  @HiveField(12)
  List<String> ads = [];

  ExternalSource({
    required this.name,
    required this.homePage,
    required this.iconUrl,
    required this.category,
    required this.categories,
    required this.categoryUrl,
    required this.supportsCustomCategory,
    required this.categoryArticles,
    required this.searchUrl,
    required this.searchArticles,
    required this.article,
    required this.headers,
    required this.ads,
  });

  ExternalSource.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    homePage = json['home-page'];
    iconUrl = json['icon-url'];
    category = json['category'].cast<String>();
    categories = Categories.fromJson(json['categories']);
    categoryUrl = json['category-url'];
    supportsCustomCategory = json['supports-custom-category'];
    categoryArticles = SourceArticle.fromJson(json['category-articles']);
    searchUrl = json['search-url'];
    searchArticles = SourceArticle.fromJson(json['search-articles']);
    article = SourceArticle.fromJson(json['article']);
    headers = Headers.fromJson(json['headers']);
    ads = json['ads'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['home-page'] = homePage;
    data['icon-url'] = iconUrl;
    data['category'] = category;
    data['categories'] = categories.toJson();
    data['category-url'] = categoryUrl;
    data['supports-custom-category'] = supportsCustomCategory;
    data['category-articles'] = categoryArticles.toJson();
    data['search-url'] = searchUrl;
    data['search-articles'] = searchArticles.toJson();
    data['article'] = article.toJson();
    data['headers'] = headers.toJson();
    data['ads'] = ads;
    return data;
  }
}

@HiveType(typeId: 6)
class Categories {
  @HiveField(0)
  String extractor = "";
  @HiveField(1)
  List<String> locator = [];
  @HiveField(2)
  Include include = Include.fromJson({});
  @HiveField(3)
  List<String> exclude = [];

  Categories({
    required this.extractor,
    required this.locator,
    required this.include,
    required this.exclude,
  });

  Categories.empty();

  Categories.fromJson(Map<String, dynamic> json) {
    extractor = json['extractor'];
    locator = json['locator'].cast<String>();
    include = Include.fromJson(json['include'].cast<String, String>());
    exclude = json['exclude'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['extractor'] = extractor;
    data['locator'] = locator;
    data['include'] = include.toJson();
    data['exclude'] = exclude;
    return data;
  }
}

@HiveType(typeId: 7)
class SourceArticle {
  @HiveField(0)
  String extractor = "";
  @HiveField(1)
  Locators locators = Locators.empty();
  @HiveField(2)
  String timezone = "";
  @HiveField(3)
  String dateFormat = "";
  @HiveField(4)
  List<String> modifications = [];

  SourceArticle({
    required this.extractor,
    required this.locators,
    required this.timezone,
    required this.dateFormat,
    required this.modifications,
  });

  SourceArticle.empty();

  SourceArticle.fromJson(Map<String, dynamic> json) {
    extractor = json['extractor'];
    locators = Locators.fromJson(json['locators']);
    timezone = json['timezone'];
    dateFormat = json['date-format'];
    modifications = json['modifications'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['extractor'] = extractor;
    data['locators'] = locators;
    data['details'] = locators.toJson();
    data['timezone'] = timezone;
    data['date-format'] = dateFormat;
    modifications = data['modifications'];
    return data;
  }
}

@HiveType(typeId: 8)
class Locators {
  @HiveField(0)
  String container = "";
  @HiveField(1)
  String title = "";
  @HiveField(2)
  String excerpt = "";
  @HiveField(3)
  String author = "";
  @HiveField(4)
  String thumbnail = "";
  @HiveField(5)
  String url = "";
  @HiveField(6)
  String time = "";
  @HiveField(7)
  List<String> tags = [];
  @HiveField(8)
  String category = "";
  @HiveField(9)
  List<String> content = [];

  Locators({
    required this.container,
    required this.title,
    required this.content,
    required this.url,
    required this.excerpt,
    required this.author,
    required this.time,
    required this.category,
    required this.tags,
    required this.thumbnail,
  });

  Locators.empty();

  Locators.fromJson(Map<String, dynamic> json) {
    container = json['container'];
    title = json['title'];
    excerpt = json['excerpt'];
    author = json['author'];
    thumbnail = json['thumbnail'];
    url = json['url'];
    time = json['time'];
    tags = json['tags'].cast<String>();
    category = json['category'];
    content = json['content'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['container'] = container;
    data['title'] = title;
    data['excerpt'] = excerpt;
    data['author'] = author;
    data['thumbnail'] = thumbnail;
    data['url'] = url;
    data['time'] = time;
    data['tags'] = tags;
    data['category'] = category;
    data['content'] = content;
    return data;
  }
}

@HiveType(typeId: 10)
class Headers {
  @HiveField(0)
  Map<String, dynamic> json_ = {};

  Headers({required this.json_});

  Headers.fromJson(Map<String, dynamic> json) {
    json_ = json;
  }

  Map<String, dynamic> toJson() {
    return json_;
  }
}

@HiveType(typeId: 9)
class Include {
  @HiveField(0)
  Map<String, String> json_ = {};

  Include({required this.json_});

  Include.fromJson(Map<String, String> json) {
    json_ = json;
  }

  Map<String, String> toJson() {
    return json_;
  }
}
