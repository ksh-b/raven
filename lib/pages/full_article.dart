import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:raven/api/simplytranslate.dart';
import 'package:raven/model/article.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/store.dart';

class ArticlePage extends StatefulWidget {
  final NewsArticle article;

  const ArticlePage({super.key, required this.article});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  TextStyle metadataStyle = const TextStyle(
    fontStyle: FontStyle.italic,
    color: Colors.grey,
  );

  TextStyle titleStyle = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  TextStyle excerptStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  Stream<NewsArticle> customArticle(NewsArticle newsArticle, BuildContext context) async* {
    NewsArticle cArticle = await newsArticle.publisher.article(newsArticle);

    if (Store.translate) {
      var translator = SimplyTranslate();
      cArticle.title =
      await translator.translate(cArticle.title, Store.languageSetting);
      yield cArticle;
      cArticle.content =
      await translator.translate(cArticle.content, Store.languageSetting);
      yield cArticle;
      cArticle.excerpt =
      await translator.translate(cArticle.excerpt, Store.languageSetting);
      yield cArticle;
    }

    yield cArticle;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NewsArticle>(
      initialData: widget.article,
      stream: customArticle(widget.article, context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String fullUrl =
              "${widget.article.publisher.homePage}${snapshot.data!.url}";
          String altUrl = "${Store.ladderUrl}/$fullUrl";
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.article.publisher.name),
              actions: [
                InkWell(
                  onLongPress: () {
                    Share.shareUri(Uri.parse(altUrl));
                  },
                  child: IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      Share.shareUri(Uri.parse(fullUrl));
                    },
                  ),
                ),
                InkWell(
                  onLongPress: () {
                    launchUrl(Uri.parse(altUrl));
                  },
                  child: IconButton(
                    icon: Icon(Icons.open_in_browser),
                    onPressed: () {
                      launchUrl(Uri.parse(fullUrl));
                    },
                  ),
                ),
              ],
            ),
            body: (snapshot.hasData)
                ? Padding(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: ListView(
                      children: [
                        snapshot.connectionState != ConnectionState.done ? LinearProgressIndicator():SizedBox.shrink(),
                        textWidget("", snapshot.data!.title, titleStyle),
                        textWidget(
                            "Author", snapshot.data!.author, metadataStyle),
                        textWidget("Published",
                            snapshot.data!.publishedAt.value, metadataStyle),
                        if (Network.shouldLoadImage(snapshot.data!.thumbnail))
                          image(snapshot),
                        textWidget("", snapshot.data!.excerpt, excerptStyle),
                        HtmlWidget(snapshot.data!.content),
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: ListView(
                      children: [
                        textWidget("", widget.article.title, titleStyle),
                        textWidget(
                            "Author", widget.article.author, metadataStyle),
                        textWidget("Published",
                            widget.article.publishedAt.value, metadataStyle),
                        LinearProgressIndicator(),
                        textWidget("", widget.article.excerpt, excerptStyle),
                        widget.article.content.isNotEmpty
                            ? HtmlWidget(widget.article.content)
                            : LinearProgressIndicator(),
                      ],
                    ),
                  ),
          );
        }
        else if (snapshot.hasError) {
          String fallbackUrl =
              "${widget.article.publisher.homePage}${widget.article.url}";
          return Scaffold(
            appBar: AppBar(),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Error loading article\n$fallbackUrl"),
                    IconButton(
                      onPressed: () {
                        launchUrl(Uri.parse(fallbackUrl));
                      },
                      icon: Icon(Icons.open_in_browser),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Padding image(AsyncSnapshot<NewsArticle> snapshot) {
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

  Widget textWidget(
    String label,
    String value,
    TextStyle style,
  ) {
    if (value.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
        child: Text(
          label.isNotEmpty ? '$label: $value' : value,
          style: style,
        ),
      );
    } else {
      return SizedBox.shrink();
    }
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
      doNotRenderTheseTags: const {"noscript"},
      extensions: [
        TagExtension(
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
        ),
      ],
    );
  }
}
