import 'package:raven/model/publisher.dart';

class NewsArticle {
  Publisher publisher;
  String title;
  String content;
  String excerpt;
  String author;
  String url;
  String thumbnail;
  String category;
  List<String> tags;
  int publishedAt;

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
      'publisher': publisher.toJson(),
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
