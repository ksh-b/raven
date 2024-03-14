import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:whapp/brain/article_provider.dart';
import 'package:whapp/model/article.dart';
import 'package:whapp/model/trends.dart';

import 'package:whapp/pages/full_article.dart';
import 'package:whapp/utils/store.dart';
import 'package:whapp/utils/string.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with AutomaticKeepAliveClientMixin {
  List<NewsArticle> newsArticles = [];
  ArticleProvider articleProvider = ArticleProvider();
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  double loadProgress = 0;
  int page = 1;
  HashMap<int, dynamic> subscriptionPage = HashMap();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('What\'s happening?'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: MySearchDelegate(),
                );
              },
            ),
          ],
        ),
        body: FutureBuilder(
          future: articleProvider.loadPage(page, query: null),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FeedPageBuilder(null, snapshot.data!);
            } else if (snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(),);
            } else if(snapshot.hasError){
              return Center(child: Text(snapshot.error.toString()));
            } else {
              return Center(child: Text("No data"));
            }
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage(this.query, {super.key});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  List<NewsArticle> newsArticles = [];
  ArticleProvider articleProvider = ArticleProvider();
  bool isLoading = false;
  double loadProgress = 0;
  int page = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: articleProvider.loadPage(page, query: widget.query),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return FeedPageBuilder(widget.query, snapshot.data!);
        } else if (snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator(),);
        } else {
          return Center(child: Text("No data"));
        }
      },
    );
  }
}

class FeedPageBuilder extends StatefulWidget {
  final String? query;
  final List<NewsArticle> newsArticles;

  const FeedPageBuilder(this.query, this.newsArticles, {super.key});

  @override
  State<FeedPageBuilder> createState() => _FeedPageBuilderState();
}

class _FeedPageBuilderState extends State<FeedPageBuilder> {
  late List<NewsArticle> newsArticles;
  late ArticleProvider articleProvider;
  late bool isLoading;
  late double loadProgress;
  late int page;
  late GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;

  @override
  void initState() {
    super.initState();
    setState(() {
      newsArticles = widget.newsArticles;
    });
    articleProvider = ArticleProvider();
    isLoading = false;
    loadProgress = 0;
    page = 1;
    _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      strokeWidth: 4.0,
      onRefresh: () async {
        setState(() {
          newsArticles = [];
          page = 1;
        });
        articleProvider = ArticleProvider();
        articleProvider.loadPage(page, query: widget.query).then(
              (value) => setState(
                () {
                  newsArticles += value;
                },
              ),
            );
      },
      child: ValueListenableBuilder(
        valueListenable: Store.subscriptions.listenable(),
        builder: (BuildContext context, box, Widget? child) {
          if (Store.selectedSubscriptions.isNotEmpty) {
            return ListView.builder(
              itemCount: newsArticles.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return isLoading
                      ? LinearProgressIndicator(
                          value: loadProgress,
                        )
                      : SizedBox.shrink();
                }
                if (index - 1 < newsArticles.length) {
                  var article = newsArticles[index - 1];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: FeedCard(article: article),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              page += 1;
                              setState(() {
                                isLoading = true;
                              });
                              articleProvider
                                  .loadPage(page, query: widget.query)
                                  .then(
                                    (value) => setState(
                                      () => newsArticles += value,
                                    ),
                                  )
                                  .whenComplete(
                                    () => setState(() => isLoading = false),
                                  );
                            },
                      child: Text(isLoading ? "Loading" : "Load more"),
                    ),
                  );
                }
              },
            );
          }
          return Center(child: Text("Select some subscriptions"));
        },
      ),
    );
  }
}

class MySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return SearchResultsPage(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: trends[Store.trendsProviderSetting]?.topics,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView(
            children: snapshot.data!
                .map((e) => ListTile(
                      leading: Icon(Icons.trending_up_rounded),
                      title: Text(e),
                      onTap: () {
                        query = e;
                        showResults(context);
                      },
                    ))
                .toList(),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator(),);
        } else if(snapshot.hasError){
          return Center(child: Text(snapshot.error.toString()));
        } else {
          return Center(child: Text("No data"));
        }
      },
    );
  }
}

class FeedCard extends StatelessWidget {
  const FeedCard({
    super.key,
    required this.article,
  });

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0), // Adjust the radius as needed
        child: InkWell(
          child: Flex(
            direction: Axis.vertical,
            children: [
              Store.loadImagesSetting == "Always"
                  ? Stack(
                      children: [
                        ArticleThumbnail(article: article),
                        ArticleTags(article: article),
                      ],
                    )
                  : SizedBox.shrink(),
              ListTile(
                title: Text(article.title),
                leading: ArticlePublisherIcon(article: article),
                subtitle: Text(
                  article.publishedAt.value,
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArticlePage(article: article),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ArticlePublisherIcon extends StatelessWidget {
  const ArticlePublisherIcon({
    super.key,
    required this.article,
  });

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: article.publisher.iconUrl,
      progressIndicatorBuilder: (context, url, downloadProgress) {
        return CircularProgressIndicator(
          value: downloadProgress.progress,
        );
      },
      height: 24,
      width: 24,
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}

class ArticleTags extends StatelessWidget {
  const ArticleTags({
    super.key,
    required this.article,
  });

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(4.0),
        child: Row(
          children: article.tags
              .where((element) =>
                  element.length > 1 && element.toLowerCase() != "news")
              .take(2)
              .map((e) => Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4),
                    child: Chip(
                      // avatar: Icon(Icons.tag),
                      label: Text(
                        createTag(e),
                        style: TextStyle(fontSize: 10),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      backgroundColor: Colors.white,
                      labelPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class ArticleThumbnail extends StatelessWidget {
  const ArticleThumbnail({
    super.key,
    required this.article,
  });

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      width: MediaQuery.of(context).size.width,
      fit: BoxFit.fill,
      imageUrl: article.thumbnail,
      progressIndicatorBuilder: (context, url, progress) =>
          Stack(alignment: AlignmentDirectional.bottomCenter, children: [
        SizedBox(
          height: 200,
        ),
        LinearProgressIndicator(
          value: progress.progress,
        )
      ]),
      errorWidget: (context, url, error) {
        return SizedBox.shrink();
      },
    );
  }
}
