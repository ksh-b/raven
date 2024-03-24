import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:raven/brain/article_provider.dart';
import 'package:raven/model/article.dart';
import 'package:raven/pages/full_article.dart';
import 'package:raven/utils/store.dart';
import 'package:raven/utils/string.dart';

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
          isLoading = true;
        });
        loadMore();
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
                          : loadMore,
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

  void loadMore() {
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
              Store.loadImagesSetting
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
