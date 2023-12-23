import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:whapp/model/article.dart';
import 'package:whapp/model/publisher.dart';
import 'package:whapp/model/user_subscription.dart';

import 'package:whapp/pages/full_article.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with AutomaticKeepAliveClientMixin {
  List<NewsArticle?> newsArticles = [];
  bool isLoading = false;
  int page = 1;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    _loadMoreItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        strokeWidth: 4.0,
        onRefresh: () async {
          setState(() {
            newsArticles = [];
            page = 1;
          });
          _loadMoreItems();
        },
        child: ListView.builder(
          itemCount: newsArticles.length + 1,
          itemBuilder: (context, index) {
            if (index < newsArticles.length) {
              return ListTile(
                title: Text(newsArticles[index]!.title),
                leading: CachedNetworkImage(
                  imageUrl: newsArticles[index]!.publisher.iconUrl,
                  progressIndicatorBuilder: (context, url, downloadProgress) {
                    return CircularProgressIndicator(value: downloadProgress.progress);
                  },
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                subtitle: Text(
                  "${newsArticles[index]!.author} - ${newsArticles[index]!.publishedAt.value}",
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ArticlePage(article: newsArticles[index]!)),
                  );
                },
              );
            } else {
              return ElevatedButton(
                onPressed: () {
                  _loadMoreItems();
                },
                child: const Text("Load more"),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _loadMoreItems() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      List subscriptions = Hive.box("subscriptions").get("selected") ??
          List<UserSubscription>.empty(growable: true);
      for (var subscription in subscriptions) {
        Publisher publisher = publishers[subscription.publisher]!;
        publisher
            .articles(page: page, category: subscription.category)
            .then((articles) {
          setState(() {
            newsArticles = newsArticles.toSet().union(articles).toList()
              ..sort((a, b) => a?.publishedAt.key.compareTo(b?.publishedAt.key),);
            isLoading = false;
          });
        });
      }

      setState(() {
        isLoading = false;
        page++;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;
}
