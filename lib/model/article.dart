import 'package:whapp/model/publisher.dart';

class NewsArticle {
  Publisher publisher;
  String title;
  String content;
  String excerpt;
  String author;
  String url;
  String thumbnail;
  MapEntry<int, String> publishedAt;

  NewsArticle(
    this.publisher,
    this.title,
    this.content,
    this.excerpt,
    this.author,
    this.url,
    this.thumbnail,
    this.publishedAt,
  );

  NewsArticle fill({
    String? title,
    String? content,
    String? excerpt,
    String? author,
    String? url,
    String? thumbnail,
    MapEntry<int, String>? publishedAt,
  }) {
    return NewsArticle(
      publisher,
      title ?? this.title,
      content ?? this.content,
      excerpt ?? this.excerpt,
      author ?? this.author,
      url ?? this.url,
      thumbnail ?? this.thumbnail,
      publishedAt ?? this.publishedAt,
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
      'publishedAt': publishedAt,
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
