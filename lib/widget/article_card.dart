import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:klaws/model/article.dart';
import 'package:klaws/model/publisher.dart';
import 'package:raven/provider/theme.dart';
import 'package:raven/repository/preferences/bookmarks.dart';
import 'package:raven/repository/preferences/content.dart';
import 'package:raven/repository/preferences/saved.dart';
import 'package:raven/screen/full_article.dart';
import 'package:raven/service/favicon_extractor.dart';
import 'package:raven/service/simplytranslate.dart';
import 'package:raven/utils/time.dart';
import 'package:raven/widget/rounded_chip.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ArticleCard extends StatefulWidget {
  final Article article;
  final List<Key> keys = [];
  final bool showSaveIcon;
  final bool showBookmarkIcon;
  final bool shouldLoadArticle;
  final bool deleteSaved;
  final bool deleteBookmarked;

  ArticleCard(
    this.article, {
    super.key,
    this.showSaveIcon = true,
    this.deleteSaved = false,
    this.showBookmarkIcon = true,
    this.deleteBookmarked = false,
    this.shouldLoadArticle = true,
  });

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> {
  @override
  Widget build(BuildContext context) {
    var filtered =
        widget.article.metadata.keys.contains(Metadata.filtered.name);

    return InkWell(
      child: filtered
          ? ExpansionTile(
              leading: Icon(Icons.hide_source_rounded),
              title: Text("Excluded based on your criteria"),
              subtitle:
                  Text(widget.article.metadata[Metadata.filtered.name] ?? ""),
              children: [
                VisibleArticleCard(widget: widget),
              ],
            )
          : VisibleArticleCard(widget: widget),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticlePage(
              widget.article,
              shouldLoad: widget.shouldLoadArticle,
            ),
          ),
        );
      },
    );
  }
}

class VisibleArticleCard extends StatefulWidget {
  VisibleArticleCard({
    super.key,
    required this.widget,
  });

  final ArticleCard widget;

  @override
  State<VisibleArticleCard> createState() => _VisibleArticleCardState();
}

class _VisibleArticleCardState extends State<VisibleArticleCard> {
  ValueNotifier<bool> saving = ValueNotifier<bool>(false);
  ValueNotifier<bool> bookmarked = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    bookmarked.value = BookmarkedArticles.contains(widget.widget.article);
    return Flex(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      direction: Axis.vertical,
      children: [
        Flexible(
          child: ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            title: ArticlePublisherDetails(widget: widget.widget),
            subtitle: Text(widget.widget.article.category),
            leading: PublisherFavicon(widget: widget.widget),
          ),
        ),
        Flexible(
          child: ListTile(
            title: ArticleTitle(widget: widget.widget),
            dense: false,
          ),
        ),
        ContentPref.shouldLoadImages
            ? Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        ArticleThumbnail(widget: widget.widget),
                        Chips(widget: widget.widget),
                      ],
                    ),
                  ),
                ),
              )
            : SizedBox.shrink(),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                (Uri.tryParse(widget.widget.article.url)?.scheme ?? "")
                        .isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.share_rounded),
                        visualDensity: VisualDensity.standard,
                        onPressed: () {
                          Share.shareUri(Uri.parse(widget.widget.article.url));
                        },
                      )
                    : SizedBox.shrink(),
                widget.widget.showBookmarkIcon
                    ? ValueListenableBuilder(
                        valueListenable: bookmarked,
                        builder: (context, value, child) {
                          return IconButton(
                            icon: value
                                ? Icon(Icons.bookmark_rounded)
                                : Icon(Icons.bookmark_outline_rounded),
                            visualDensity: VisualDensity.standard,
                            onPressed: () {
                              if (BookmarkedArticles.contains(
                                  widget.widget.article)) {
                                BookmarkedArticles.deleteArticle(
                                    widget.widget.article);
                                bookmarked.value = false;
                              } else {
                                BookmarkedArticles.saveArticle(
                                    widget.widget.article);
                                bookmarked.value = true;
                              }
                            },
                          );
                        },
                      )
                    : SizedBox.shrink(),
                widget.widget.showSaveIcon
                    ? ValueListenableBuilder(
                        valueListenable: saving,
                        builder: (BuildContext context, bool isSaving,
                            Widget? child) {
                          return IconButton(
                            icon: isSaving
                                ? CircularProgressIndicator()
                                : SavedArticles.contains(widget.widget.article)
                                    ? Icon(Icons.download_rounded)
                                    : Icon(Icons.download_outlined),
                            visualDensity: VisualDensity.standard,
                            onPressed: !isSaving
                                ? () async {
                                    saving.value = true;
                                    await saveArticle();
                                    saving.value = false;
                                  }
                                : null,
                          );
                        },
                      )
                    : SizedBox.shrink(),
                widget.widget.deleteBookmarked
                    ? ValueListenableBuilder(
                        valueListenable: saving,
                        builder: (
                          BuildContext context,
                          bool isSaving,
                          Widget? child,
                        ) {
                          return IconButton(
                            icon: Icon(Icons.delete_forever_rounded),
                            visualDensity: VisualDensity.standard,
                            onPressed: !isSaving
                                ? () async {
                                    BookmarkedArticles.deleteArticle(
                                      widget.widget.article,
                                    );
                                  }
                                : null,
                          );
                        },
                      )
                    : SizedBox.shrink(),
                widget.widget.deleteSaved
                    ? ValueListenableBuilder(
                  valueListenable: saving,
                  builder: (
                      BuildContext context,
                      bool isSaving,
                      Widget? child,
                      ) {
                    return IconButton(
                      icon: Icon(Icons.delete_forever_rounded),
                      visualDensity: VisualDensity.standard,
                      onPressed: !isSaving
                          ? () async {
                        SavedArticles.deleteArticle(widget.widget.article);
                      }
                          : null,
                    );
                  },
                )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> saveArticle() async {
    Article article =
        await SimplyTranslate().translateArticle(widget.widget.article);
    SavedArticles.saveArticle(article);
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
    String relativeTime = unixToString(widget.article.publishedAt);
    if (relativeTime.isNotEmpty) {
      relativeTime = " • $relativeTime";
    }
    return Text(
      "${widget.article.sourceName}$relativeTime",
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
    return Flex(
      direction: Axis.horizontal,
      children: [
        Expanded(
          child: widget.article.thumbnail.isNotEmpty
              ? CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: widget.article.thumbnail,
                  placeholder: (context, url) {
                    return Container(color: Colors.black38, height: 200);
                  },
                  errorWidget: (context, url, error) {
                    return SizedBox.shrink();
                  },
                )
              : SizedBox.shrink(),
        ),
      ],
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
    Source publisher = widget.article.source;
    if (["rss", "morss"].contains(publisher.id)) {
      return CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(
            FaviconExtractor.favicon(widget.article.category)),
      );
    }
    return CircleAvatar(
      backgroundImage: CachedNetworkImageProvider(publisher.iconUrl),
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
