import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:raven/api/simplytranslate.dart';
import 'package:raven/brain/article_provider.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/pages/full_article.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/store.dart';
import 'package:raven/utils/string.dart';
import 'package:raven/utils/theme_provider.dart';
import 'package:raven/utils/time.dart';

class FeedPageBuilder extends StatefulWidget {
  final String? query;
  final bool saved;

  const FeedPageBuilder({super.key, this.query, this.saved = false});

  @override
  State<FeedPageBuilder> createState() => _FeedPageBuilderState();
}

class _FeedPageBuilderState extends State<FeedPageBuilder> {
  List<NewsArticle> newsArticles = [];
  bool isLoading = false;
  ArticleProvider articleProvider = ArticleProvider();
  int page = 0;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: refresh,
      child: ValueListenableBuilder(
        valueListenable: Store.subscriptions.listenable(),
        builder: (BuildContext context, box, Widget? child) {
          if (Store.selectedSubscriptions.isNotEmpty) {
            return ListView.builder(
              itemCount: newsArticles.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return isLoading
                      ? LinearProgressIndicator()
                      : SizedBox.shrink();
                }
                if (index - 1 < newsArticles.length) {
                  var article = newsArticles[index - 1];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: Slidable(
                      key: Key(article.url),
                      startActionPane: ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            backgroundColor:
                                ThemeProvider().getCurrentTheme().cardColor,
                            foregroundColor: ThemeProvider()
                                .getCurrentTheme()
                                .textTheme
                                .titleMedium!
                                .color,
                            onPressed: (context) {
                              article.load().then((value) {
                                Store.saveArticle(value);
                              });
                            },
                            icon: Icons.save,
                            label: "Save",
                          )
                        ],
                      ),
                      child: FeedCard(article: article),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : loadMore,
                      child: Text(isLoading ? "Loading" : "Load more"),
                    ),
                  );
                }
              },
            );
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 64, right: 64),
              child: Flex(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                direction: Axis.vertical,
                children: [
                  Icon(Icons.checklist_rounded),
                  SizedBox(height: 32),
                  Text("Select some subscriptions to get started")
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> refresh() async {
    setState(() {
      newsArticles = [];
      page = 0;
      isLoading = true;
    });
    articleProvider.reset();
    loadMore();
  }

  void loadMore() {
    setState(() {
      page += 1;
      isLoading = true;
    });

    articleProvider.loadPage(page, query: widget.query).then((value) async {
      if (Store.shouldTranslate) {
        var originalTitles = value.map((e) {
          if (e.title.isEmpty) e.title = ".";
          return e.title.replaceAll("\n", "");
        }).toList();
        var translated = await SimplyTranslate().translate(
          originalTitles,
          Store.languageSetting,
        );
        var translatedTitles = translated;
        if (value.length == translatedTitles.length) {
          for (var i = 0; i < value.length; i++) {
            value[i].title = translatedTitles[i];
          }
        }
      }
      setState(() {
        newsArticles += value;
      });
    }).whenComplete(
      () {
        setState(() {
          isLoading = false;
        });
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
                subtitle: article.publishedAt != -1
                    ? Text(
                        unixToString(article.publishedAt),
                      )
                    : SizedBox.shrink(),
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
      imageUrl: publishers[article.publisher]!.iconUrl,
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
    if (!Network.shouldLoadImage(article.thumbnail)) {
      return SizedBox.shrink();
    }
    return CachedNetworkImage(
      width: MediaQuery.of(context).size.width,
      fit: BoxFit.fill,
      imageUrl: article.thumbnail,
      progressIndicatorBuilder: (context, url, progress) =>
          Stack(alignment: AlignmentDirectional.bottomCenter, children: [
        SizedBox(
          height: 200,
        ),
        LinearProgressIndicator()
      ]),
      errorWidget: (context, url, error) {
        return SizedBox.shrink();
      },
    );
  }
}
