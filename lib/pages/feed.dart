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

class _FeedPageState extends State<FeedPage>
    with AutomaticKeepAliveClientMixin {
  List<NewsArticle?> newsArticles = [];
  List<NewsArticle?> filteredArticles = [];
  TextEditingController searchController = TextEditingController();
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
    return SafeArea(
      child: Scaffold(
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
          child:ValueListenableBuilder(
            valueListenable: Hive.box('subscriptions').listenable(),
            builder: (BuildContext context, box, Widget? child) {
              if(box.get("selected")!=null && box.get("selected").isNotEmpty) {
                return ListView.builder(
                itemCount: filteredArticles.length + 2,
                itemBuilder: (context, index) {
                  if(index==0){
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            filteredArticles = newsArticles
                                .where((article) =>
                                article!.title.toLowerCase().contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Search News',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30.0), // Adjust the value as needed
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  else if (index-1 < filteredArticles.length) {
                    var article = filteredArticles[index-1];
                    return ListTile(
                      title: Text(article!.title),
                      leading: CachedNetworkImage(
                        imageUrl: article.publisher.iconUrl,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) {
                          return CircularProgressIndicator(
                              value: downloadProgress.progress);
                        },
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                      ),
                      subtitle: Text(
                        "${article.author} - ${article.publishedAt.value}",
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ArticlePage(article: article)),
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
              );
              } return Center(child: Text("Select some subscriptions"));
            },
          ),
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
              ..sort(
                (a, b) => a?.publishedAt.key.compareTo(b?.publishedAt.key),
              );
            filteredArticles = List.from(newsArticles);
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
