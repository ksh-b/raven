import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:klaws/model/article.dart';
import 'package:raven/repository/preferences/saved.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/string.dart';
import 'package:raven/widget/article_card.dart';
import 'package:raven/widget/blank_page_message.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved"),
      ),
      body: ValueListenableBuilder(
        valueListenable: SavedArticles.saved.listenable(),
        builder: (BuildContext context, box, Widget? child) {
          if (SavedArticles.saved.isNotEmpty) {
            return ListView.separated(
              itemCount: SavedArticles.saved.keys.length,
              itemBuilder: (context, index) {
                Article article = SavedArticles.saved.values.toList()[index];
                return ArticleCard(
                  article,
                  showSaveIcon: false,
                  showBookmarkIcon: true,
                  deleteSaved: true,
                  shouldLoadArticle: false,
                );
              },
              separatorBuilder: (BuildContext context, int index) => Divider(),
            );
          }
          return const BlankPageMessage(
            "No articles saved",
          );
        },
      ),
    );
  }
}

class ArticlePublisherIcon extends StatelessWidget {
  const ArticlePublisherIcon({
    super.key,
    required this.article,
  });

  final Article article;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: article.source.iconUrl,
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

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(4.0),
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

  final Article article;

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
          SizedBox(height: 200),
          LinearProgressIndicator(),
        ],
      ),
      errorWidget: (context, url, error) {
        return const SizedBox.shrink();
      },
    );
  }
}
