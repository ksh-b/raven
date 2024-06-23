import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:raven/brain/article_provider.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/pages/full_article.dart';
import 'package:raven/service/simplytranslate.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/store.dart';
import 'package:raven/utils/string.dart';
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
  List<NewsArticle> filteredNewsArticles = [];
  Map<String, int> tags = {};
  Set<String> selectedTags = {};
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
        builder: (BuildContext context, value, Widget? child) {
          return Store.selectedSubscriptions.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Store.showTagListSetting?SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: tags.keys
                              .map(
                                (key) => Padding(
                                  padding:
                                      const EdgeInsets.only(left: 4, right: 4),
                                  child: ChoiceChip(
                                    label: Text(key),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(24.0)),
                                    selected: selectedTags.contains(key),
                                    avatar: Text("${tags[key]}"),
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          selectedTags = selectedTags..add(key);
                                        } else {
                                          selectedTags = selectedTags
                                            ..remove(key);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ):SizedBox.shrink(),
                    ),
                    Flexible(
                      child: ListView.builder(
                        itemCount: filterNewsArticle(
                                    newsArticles, selectedTags.toList())
                                .length +
                            2,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return isLoading
                                ? const LinearProgressIndicator()
                                : const SizedBox.shrink();
                          }
                          if (index - 1 <
                              filterNewsArticle(
                                      newsArticles, selectedTags.toList())
                                  .length) {
                            var article = filterNewsArticle(
                                newsArticles, selectedTags.toList())[index - 1];
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                              child: Dismissible(
                                key: Key(article.url),
                                direction: DismissDirection.startToEnd,
                                background: Container(
                                  child: Align(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: Icon(Icons.save_alt_rounded),
                                    ),
                                    alignment: Alignment.centerLeft,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  if (direction == DismissDirection.startToEnd) {
                                    article
                                        .load(translate: true)
                                        .then((value) {
                                      value.tags += ["saved"];
                                      Store.saveArticle(value);
                                    });
                                    return false;
                                  }
                                  return null;
                                },
                                child: FeedCard(article: article),
                              ),
                            );
                          } else {
                            return Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 32, 16, 16),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : loadMore,
                                child:
                                    Text(isLoading ? "Loading" : "Load more"),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Padding(
                    padding: EdgeInsets.only(left: 64, right: 64),
                    child: Flex(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      direction: Axis.vertical,
                      children: [
                        Icon(Icons.checklist_rounded),
                        SizedBox(height: 32),
                        Text("Select some subscriptions to get started"),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }

  List<NewsArticle> filterNewsArticle(
      List<NewsArticle> articles, List<String> tags) {
    List<NewsArticle> fArticles = articles
        .where(
            (element) => element.tags.any((element) => tags.contains(element)))
        .toList();
    return fArticles.isEmpty ? articles : fArticles;
  }

  Future<void> refresh() async {
    setState(() {
      newsArticles = [];
      page = 0;
      isLoading = true;
    });
    articleProvider.reset();
    if (await Network.isConnected()) {
      loadMore();
    } else {
      setState(() {
        newsArticles = Store.getOfflineArticles();
        isLoading = false;
      });
    }
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
        var translated = await SimplyTranslate().translateSentences(
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
        if (page == 1 && newsArticles.isNotEmpty) {
          Store.saveOfflineArticles(newsArticles);
        }
        for (var article in newsArticles) {
          for (var tag in article.tags) {
            tags.update(tag, (value) => (tags[tag] ?? 1) + 1,
                ifAbsent: () => 1);
          }
        }
        List<MapEntry<String, int>> entries = tags.entries.toList();
        entries.sort((e1, e2) => tags[e2.key]!.compareTo(tags[e1.key]!));

        tags = Map.fromEntries(entries);
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
        borderRadius: BorderRadius.circular(8.0),
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
                    : const SizedBox.shrink(),
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
                      label: Text(
                        createTag(e),
                        style: const TextStyle(fontSize: 10),
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
      return const SizedBox.shrink();
    }
    return CachedNetworkImage(
      width: MediaQuery.of(context).size.width,
      fit: BoxFit.fill,
      imageUrl: article.thumbnail,
      progressIndicatorBuilder: (context, url, progress) => const Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          SizedBox(
            height: 200,
          ),
          LinearProgressIndicator(),
        ],
      ),
      errorWidget: (context, url, error) {
        return const SizedBox.shrink();
      },
    );
  }
}
