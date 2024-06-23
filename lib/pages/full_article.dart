import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:raven/brain/fallback_provider.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/pages/widget/options_popup.dart';
import 'package:raven/service/simplytranslate.dart';
import 'package:raven/utils/html_helper.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/store.dart';
import 'package:raven/utils/time.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticlePage extends StatefulWidget {
  final NewsArticle article;

  const ArticlePage({super.key, required this.article});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  Stream<NewsArticle> customArticle(
    NewsArticle newsArticle,
    BuildContext context,
  ) async* {
    if (newsArticle.tags.contains("saved")) {
      yield newsArticle;
    } else if (newsArticle.content.isNotEmpty &&
        !Store.shouldTranslate &&
        publishers[newsArticle.publisher]!.mainCategory != Category.custom) {
      yield newsArticle;
    } else {
      NewsArticle cArticle = await newsArticle.load();
      yield cArticle;

      if (Store.shouldTranslate) {
        var translator = SimplyTranslate();

        var excerpt = (await translator.translateSentences(
          [cArticle.excerpt],
          Store.languageSetting,
        ));
        cArticle.excerpt = excerpt.isNotEmpty ? excerpt.first : "";
        yield cArticle;

        cArticle.content = (await translator.translateParagraph(
          cleanHtml(cArticle.content).join(),
          Store.languageSetting,
        ));
        yield cArticle;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fullUrl =
        "${publishers[widget.article.publisher]!.homePage}${widget.article.url}";
    return StreamBuilder<NewsArticle>(
      initialData: widget.article,
      stream: customArticle(widget.article, context),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text(publishers[widget.article.publisher]!.name),
            actions: [
              ShareButton(fullUrl: fullUrl),
              OpenUrlButton(fullUrl: fullUrl),
            ],
          ),
          body: snapshot.hasData
              ? SuccessArticle(snapshot)
              : FallbackArticle(widget.article, fullUrl),
        );
      },
    );
  }
}

class OpenUrlButton extends StatelessWidget {
  const OpenUrlButton({
    super.key,
    required this.fullUrl,
  });

  final String fullUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        showPopup(
          context,
          "Prefix URL with...",
          (String option) {
            launchUrl(Uri.parse("${Store.ladders[option]!}/$fullUrl"));
          },
          Store.ladders.keys.toList(),
        );
      },
      child: IconButton(
        icon: Icon(Icons.open_in_browser),
        onPressed: () {
          launchUrl(Uri.parse(fullUrl));
        },
      ),
    );
  }
}

class ShareButton extends StatelessWidget {
  const ShareButton({
    super.key,
    required this.fullUrl,
  });

  final String fullUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        showPopup(
          context,
          "Prefix URL with...",
          (String option) {
            Share.shareUri(Uri.parse("${Store.ladders[option]!}/$fullUrl"));
          },
          Store.ladders.keys.toList(),
        );
      },
      child: IconButton(
        icon: Icon(Icons.share),
        onPressed: () {
          Share.shareUri(Uri.parse(fullUrl));
        },
      ),
    );
  }
}

class SuccessArticle extends StatelessWidget {
  final AsyncSnapshot<NewsArticle> snapshot;

  SuccessArticle(this.snapshot, {super.key});

  @override
  Widget build(BuildContext context) {
    String selectedText = "";
    TextStyle metadataStyle = const TextStyle(
      fontStyle: FontStyle.italic,
      color: Colors.grey,
    );

    TextStyle titleStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    TextStyle excerptStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: SelectionArea(
        onSelectionChanged: (value) {
          selectedText = value?.plainText ?? "";
        },
        contextMenuBuilder: (mContext, selectableRegionState) {
          final List<ContextMenuButtonItem> buttonItems =
              selectableRegionState.contextMenuButtonItems;
          buttonItems.add(
            ContextMenuButtonItem(
              label: 'Translate',
              onPressed: () {
                showModalBottomSheet(
                  context: mContext,
                  builder: (context) {
                    return Container(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: SingleChildScrollView(
                          child: TranslatedText(
                            text: selectedText,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
          return AdaptiveTextSelectionToolbar.buttonItems(
            anchors: selectableRegionState.contextMenuAnchors,
            buttonItems: buttonItems,
          );
        },
        child: ListView(
          children: [
            snapshot.connectionState != ConnectionState.done
                ? LinearProgressIndicator()
                : SizedBox.shrink(),
            TextWidget("", snapshot.data!.title, titleStyle),
            TextWidget("Author", snapshot.data!.author, metadataStyle),
            TextWidget(
              "Published",
              unixToString(snapshot.data!.publishedAt),
              metadataStyle,
            ),
            if (Network.shouldLoadImage(snapshot.data!.thumbnail))
              Image(snapshot),
            TextWidget("", snapshot.data!.excerpt, excerptStyle),
            HtmlWidget(snapshot.data!.content),
          ],
        ),
      ),
    );
  }
}

class TranslatedText extends StatefulWidget {
  final String text;

  const TranslatedText({super.key, required this.text});

  @override
  State<TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SimplyTranslate().translate(widget.text, Store.languageSetting),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!);
        }
        return Text("Translating...");
      },
    );
  }
}

class HtmlWidget extends StatelessWidget {
  final String content;

  const HtmlWidget(
    this.content, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Html(
      data: content,
      onAnchorTap: (url, attributes, element) {
        if (url != null) {
          canLaunchUrl(Uri.parse(url))
              .then((value) => launchUrl(Uri.parse(url)));
        }
      },
      extensions: [
        TagExtension(
          tagsToExtend: {"noscript"},
          builder: (extensionContext) {
            return Html(
              data: extensionContext.innerHtml,
              extensions: [imageExtension()],
            );
          },
        ),
        imageExtension(),
      ],
    );
  }

  TagExtension imageExtension() {
    return TagExtension(
      tagsToExtend: {"img"},
      builder: (extensionContext) {
        var src = extensionContext.attributes.containsKey("data-lazy-src")
            ? "data-lazy-src"
            : "src";
        return extensionContext.attributes[src] != null &&
                Network.shouldLoadImage(extensionContext.attributes[src]!)
            ? CachedNetworkImage(
                imageUrl: extensionContext.attributes[src]!,
                progressIndicatorBuilder: (context, url, downloadProgress) {
                  return CircularProgressIndicator(
                    value: downloadProgress.progress,
                  );
                },
                errorWidget: (context, url, error) {
                  return const Icon(Icons.error);
                },
              )
            : SizedBox.shrink();
      },
    );
  }
}

class TextWidget extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle style;

  const TextWidget(this.label, this.value, this.style, {super.key});

  @override
  Widget build(BuildContext context) {
    var displayText = label.isNotEmpty && value.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      child: value.isNotEmpty
          ? Text(
              displayText
                  ? '$label: $value'
                  : value.isNotEmpty
                      ? value
                      : "",
              style: style,
            )
          : SizedBox.shrink(),
    );
  }
}

class Image extends StatelessWidget {
  final AsyncSnapshot<NewsArticle> snapshot;

  const Image(this.snapshot, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CachedNetworkImage(
        fit: BoxFit.fitWidth,
        imageUrl: snapshot.data!.thumbnail,
        progressIndicatorBuilder: (context, url, downloadProgress) {
          return Center(
            child: LinearProgressIndicator(
              value: downloadProgress.progress,
            ),
          );
        },
        errorWidget: (context, url, error) {
          return const Icon(Icons.error);
        },
      ),
    );
  }
}

class FallbackArticle extends StatelessWidget {
  final String fullUrl;
  final NewsArticle article;

  const FallbackArticle(this.article, this.fullUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FallbackProvider().get(article),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SuccessArticle(snapshot);
        } else if (snapshot.hasError) {
          return FailArticle(fullUrl);
        }
        return const Center(
          child: Flex(
            mainAxisAlignment: MainAxisAlignment.center,
            direction: Axis.vertical,
            children: [
              CircularProgressIndicator(),
              Text("Failed to load article. Trying fallback."),
            ],
          ),
        );
      },
    );
  }
}

class FailArticle extends StatelessWidget {
  final String fallbackUrl;

  const FailArticle(this.fallbackUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 64, right: 64),
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          direction: Axis.vertical,
          children: [
            const ListTile(
              title: Text("Error loading article"),
              subtitle: Text("You can try opening the url in your browser"),
            ),
            ListTile(
              leading: const Icon(Icons.open_in_browser),
              title: const Text("Open in browser"),
              onTap: () {
                launchUrl(Uri.parse(fallbackUrl));
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text("Share"),
              onTap: () {
                Share.shareUri(Uri.parse(fallbackUrl));
              },
            ),
          ],
        ),
      ),
    );
  }
}
