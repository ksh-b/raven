import 'package:flutter_test/flutter_test.dart';
import 'package:whapp/extractor/technology/torrentfreak.dart';
import 'package:whapp/model/article.dart';

void main() {
  test('TorrentFreak - Extract Categories Test', () async {
    final torrentFreak = TorrentFreak();

    final categories = await torrentFreak.categories;

    expect(categories, isA<Map<String, String>>());
    expect(categories.isNotEmpty, true);
  });

  test('TorrentFreak - Article Test', () async {
    final torrentFreak = TorrentFreak();

    const articleUrl =
        '/spammers-use-epic-games-website-to-promote-piracy-scams-231210';
    final article = await torrentFreak.article(articleUrl);

    expect(article, isA<NewsArticle>());
    expect(article?.title, isNotEmpty);
    expect(article?.content, isNotEmpty);
    expect(article?.publishedAt.value, isNot(0));
  });

  test('TorrentFreak - Category Articles Test', () async {
    final torrentFreak = TorrentFreak();

    final categoryArticles =
        await torrentFreak.categoryArticles(category: '/', page: 1);

    expect(categoryArticles, isA<Set<NewsArticle?>>());
    expect(categoryArticles, isNotEmpty);
  });

  test('TorrentFreak - Searched Articles Test', () async {
    final torrentFreak = TorrentFreak();

    const searchQuery = 'piracy';
    const page = 1;

    final searchedArticles = await torrentFreak.searchedArticles(
        searchQuery: searchQuery, page: page);

    expect(searchedArticles, isA<Set<NewsArticle?>>());
    expect(searchedArticles, isNotEmpty);
  });
}
