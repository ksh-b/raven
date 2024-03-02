import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:whapp/model/article.dart';
import 'package:whapp/model/publisher.dart';

import 'package:whapp/pages/full_article.dart';
import 'package:whapp/utils/store.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with AutomaticKeepAliveClientMixin {
  List<NewsArticle?> newsArticles = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  double loadProgress=0;
  int page = 1;
  bool _isSearching = false;
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
        appBar: AppBar(
          title: _isSearching ? TextField() : Text('What\'s happening?'),
          actions: <Widget>[
            IconButton(
              icon: Icon( _isSearching ? Icons.close: Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                });
              },
            ),
          ],
        ),
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
          child: ValueListenableBuilder(
            valueListenable: Store.subscriptions.listenable(),
            builder: (BuildContext context, box, Widget? child) {
              if (Store.selectedSubscriptions.isNotEmpty) {
                return ListView.builder(
                  itemCount: newsArticles.length + 2,
                  itemBuilder: (context, index) {
                    if(index==0) {
                      return isLoading?LinearProgressIndicator(value: loadProgress,):SizedBox.shrink();
                    }
                    if (index-1 < newsArticles.length) {
                      var article = newsArticles[index-1];
                      return Card(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0), // Adjust the radius as needed
                          child: Flex(
                            direction: Axis.vertical,
                            children: [
                              CachedNetworkImage(
                                  imageUrl: article!.thumbnail,
                                fit: BoxFit.contain,
                                errorWidget: (context, url, error) {
                                  return SizedBox.shrink();
                                },
                              ),
                              ListTile(
                                title: Text(article.title),
                                leading: CachedNetworkImage(
                                  imageUrl: article.publisher.iconUrl,
                                  progressIndicatorBuilder: (context, url, downloadProgress) {
                                    return CircularProgressIndicator(
                                      value: downloadProgress.progress,
                                    );
                                  },
                                  height: 24,
                                  width: 24,
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                                subtitle: Text(article.publishedAt.value),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ArticlePage(article: article),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            _loadMoreItems();
                          },
                          child: const Text("Load more"),
                        ),
                      );
                    }
                  },
                );
              }
              return Center(child: Text("Select some subscriptions"));
            },
          ),
        ),
      ),
    );
  }

  Future<void> _loadMoreItems() async {
    int loaded = 0;
    if (!isLoading) {
      setState(() {
        isLoading = true;
        loadProgress = 0;
      });

      List subscriptions = Store.selectedSubscriptions;
      for (var subscription in subscriptions) {
        Publisher publisher = publishers[subscription.publisher]!;
         publisher
            .articles(page: page, category: subscription.category)
            .then((articles) {
          setState(() {
            loaded+=1;
            newsArticles = newsArticles.toSet().union(articles).toList();
            loadProgress = loaded/subscriptions.length;
          });
        }).then((value) => null);
      }

      setState(() {
        isLoading = false;
        loadProgress = 0;
        page++;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;
}
