import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/pages/full_article.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/store.dart';
import 'package:raven/utils/string.dart';
import 'package:raven/utils/theme_provider.dart';
import 'package:raven/utils/time.dart';

class SavedPage extends StatefulWidget {
  final String? query;
  final bool saved;

  const SavedPage({super.key, this.query, this.saved = false});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Saved"),
        ),
        body: ValueListenableBuilder(
          valueListenable: Store.saved.listenable(),
          builder: (BuildContext context, box, Widget? child) {
            if (Store.saved.isNotEmpty) {
              return ListView.builder(
                itemCount: Store.saved.keys.length,
                itemBuilder: (context, index) {
                  var article = Store.saved.values.toList()[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: Slidable(
                      key: Key(article.url),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
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
                                Store.deleteArticle(value);
                              });
                            },
                            icon: Icons.delete,
                            label: "Delete",
                          )
                        ],
                      ),
                      child: FeedCard(article: article),
                    ),
                  );
                },
              );
            }
            return const Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 64, right: 64),
                child: const Flex(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  direction: Axis.vertical,
                  children: [
                    const Icon(Icons.bookmark_add),
                    const SizedBox(
                      height: 16,
                    ),
                    const Text(
                      "Swipe articles to the right on the feed page to save them.",
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
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
