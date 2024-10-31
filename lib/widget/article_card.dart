import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/provider/theme.dart';
import 'package:raven/repository/preferences/content.dart';
import 'package:raven/repository/preferences/saved.dart';
import 'package:raven/repository/store.dart';
import 'package:raven/screen/full_article.dart';
import 'package:raven/service/simplytranslate.dart';
import 'package:raven/utils/time.dart';
import 'package:raven/widget/rounded_chip.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ArticleCard extends StatefulWidget {
  final Article article;
  final List<Key> keys = [];

  ArticleCard(this.article, {super.key});

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> {
  @override
  Widget build(BuildContext context) {
    var filtered = widget.article.metadata.keys.contains(Metadata.filtered.name);

    return Dismissible(
      key: Key(widget.article.url),
      direction: DismissDirection.startToEnd,
      background: const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(Icons.save_alt_rounded),
        ),
      ),
      confirmDismiss: saveArticle,
      child: InkWell(
        child: filtered?ExpansionTile(
          leading: Icon(Icons.hide_source_rounded),
          title: Text("Excluded based on your criteria"),
          subtitle: Text(widget.article.metadata[Metadata.filtered.name]??""),
          children: [
            VisibleArticleCard(widget: widget),
          ],
        ):VisibleArticleCard(widget: widget),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ArticlePage(widget.article)),
          );
        },
      ),
    );
  }

  Future<bool?> saveArticle(DismissDirection direction) async {
    if (direction == DismissDirection.startToEnd) {
      Article article =
          await SimplyTranslate().translateArticle(widget.article);
      SavedArticles.saveArticle(article);
      return false;
    }
    return null;
  }
}

class VisibleArticleCard extends StatelessWidget {
  const VisibleArticleCard({
    super.key,
    required this.widget,
  });

  final ArticleCard widget;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Flex(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        direction: Axis.vertical,
        children: [
          ContentPref.shouldLoadImages?
          Flexible(
            flex: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  ArticleThumbnail(widget: widget),
                  Chips(widget: widget),
                ],
              ),
            ),
          ):SizedBox.shrink(),
          Flexible(
            flex: 4,
            child: ListTile(
              title: ArticleTitle(widget: widget),
              dense: false,
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    PublisherFavicon(widget: widget),
                    const SizedBox(
                      width: 12,
                    ),
                    ArticlePublisherDetails(widget: widget),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ArticlePublisherDetails extends StatelessWidget {
  const ArticlePublisherDetails({
    super.key,
    required this.widget,
  });

  final ArticleCard widget;

  @override
  Widget build(BuildContext context) {
    return Text(
      "${widget.article.publisher} • ${unixToString(widget.article.publishedAt)}",
    );
  }
}

class ArticleTitle extends StatefulWidget {
  const ArticleTitle({
    super.key,
    required this.widget,
  });

  final ArticleCard widget;

  @override
  State<ArticleTitle> createState() => _ArticleTitleState();
}

class _ArticleTitleState extends State<ArticleTitle> {
  bool translating = false;

  @override
  Widget build(BuildContext context) {
    ValueNotifier<String> title =
        ValueNotifier<String>(widget.widget.article.title);
    return VisibilityDetector(
      key: Key(widget.widget.article.url),
      onVisibilityChanged: (VisibilityInfo visibility) async {
        var isVisible = visibility.visibleFraction == 1;
        var firstVisit =
            !widget.widget.keys.contains(Key(widget.widget.article.url));
        if (isVisible && firstVisit) {
          setState(() {
            translating = true;
          });
          title.value = await SimplyTranslate()
              .translate(
            widget.widget.article.title,
            language: ContentPref.translateTo,
          )
              .onError(
            (error, stackTrace) {
              setState(() {
                translating = false;
              });
              return title.value;
            },
          );
          widget.widget.article.title = title.value;
          widget.widget.keys.add(Key(widget.widget.article.url));
          setState(() {
            translating = false;
          });
        }
      },
      child: ValueListenableBuilder(
        valueListenable: title,
        builder: (BuildContext context, value, Widget? child) {
          var baseColor =
              ThemeProvider().getCurrentTheme().textTheme.titleLarge!.color!;
          return translating
              ? Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: Colors.white30,
                  child: Text(value),
                )
              : Text(value);
        },
      ),
    );
  }
}

class ArticleThumbnail extends StatelessWidget {
  const ArticleThumbnail({
    super.key,
    required this.widget,
  });

  final ArticleCard widget;

  @override
  Widget build(BuildContext context) {
    if (!ContentPref.shouldLoadImages) {
      return SizedBox.shrink();
    }
    return CachedNetworkImage(
      imageUrl: widget.article.thumbnail,
      placeholder: (context, url) {
        return Container(color: Colors.black38, height: 200);
      },
      errorWidget: (context, url, error) {
        return Container(color: Colors.black38, height: 200);
      },
    );
  }
}

class PublisherFavicon extends StatelessWidget {
  const PublisherFavicon({
    super.key,
    required this.widget,
  });

  final ArticleCard widget;

  @override
  Widget build(BuildContext context) {
    Publisher publisher = Publisher.fromString(widget.article.publisher);
    return CircleAvatar(
      radius: 8,
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      child: CachedNetworkImage(
        imageUrl: publisher.iconUrl,
        placeholder: (context, url) {
          return CircleAvatar(child: Text(publisher.name.characters.first));
        },
        errorWidget: (context, url, error) {
          return CircleAvatar(child: Text(publisher.name.characters.first));
        },
      ),
    );
  }
}

class Chips extends StatelessWidget {
  const Chips({
    super.key,
    required this.widget,
  });

  final ArticleCard widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Flex(
          mainAxisSize: MainAxisSize.min,
          direction: Axis.horizontal,
          children: widget.article.tags.map((tag) => RoundedChip(tag)).toList(),
        ),
      ),
    );
  }
}
