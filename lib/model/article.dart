import 'package:hive/hive.dart';

part 'article.g.dart';

enum Metadata {
  filtered,
  translated,
  saved,
  live,
}

@HiveType(typeId: 1)
class Article {
  @HiveField(1)
  String publisher;
  @HiveField(2)
  String title;
  @HiveField(3)
  String content;
  @HiveField(4)
  String excerpt;
  @HiveField(5)
  String author;
  @HiveField(6)
  String url;
  @HiveField(7)
  String thumbnail;
  @HiveField(8)
  String category;
  @HiveField(9)
  List<String> tags;
  @HiveField(10)
  int publishedAt;
  @HiveField(11)
  Map<String, String> metadata = {};

  Article({
    required this.publisher,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.author,
    required this.url,
    required this.thumbnail,
    required this.category,
    required this.tags,
    required this.publishedAt,

  });

  Article fill({
    String? title,
    String? content,
    String? excerpt,
    String? author,
    String? url,
    String? thumbnail,
    List<String>? tags,
    int? publishedAt,
    String? category,
  }) {
    return Article(
      publisher: publisher,
      title: title ?? this.title,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      author: author ?? this.author,
      url: url ?? this.url,
      thumbnail: thumbnail ?? this.thumbnail,
      publishedAt: publishedAt ?? this.publishedAt,
      category: category ?? this.category,
      tags: this.tags,
    );
  }
}
