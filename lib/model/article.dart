import 'package:hive/hive.dart';
import 'package:raven/api/simplytranslate.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/utils/store.dart';

part 'article.g.dart';

@HiveType(typeId: 1)
class NewsArticle extends HiveObject {
  @HiveField(0) String publisher;
  @HiveField(1) String title;
  @HiveField(2) String content;
  @HiveField(3) String excerpt;
  @HiveField(4) String author;
  @HiveField(5) String url;
  @HiveField(6) String thumbnail;
  @HiveField(7) String category;
  @HiveField(8) List<String> tags;
  @HiveField(9) int publishedAt;

  NewsArticle({
    required this.publisher,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.author,
    required this.url,
    required this.thumbnail,
    this.tags = const [],
    required this.publishedAt,
    required this.category,
  });

  NewsArticle fill({
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
    return NewsArticle(
      publisher: publisher,
      title: title ?? this.title,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      author: author ?? this.author,
      url: url ?? this.url,
      thumbnail: thumbnail ?? this.thumbnail,
      publishedAt: publishedAt ?? this.publishedAt,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'publisher': publisher,
      'title': title,
      'content': content,
      'excerpt': excerpt,
      'author': author,
      'url': url,
      'thumbnail': thumbnail,
      'tags': tags,
      'publishedAt': publishedAt,
      'category': category,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsArticle &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode ^ title.hashCode;
}
