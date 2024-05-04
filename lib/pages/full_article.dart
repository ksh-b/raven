import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:raven/api/simplytranslate.dart';
import 'package:raven/api/smort.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
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
  TextStyle metadataStyle = const TextStyle(
    fontStyle: FontStyle.italic,
    color: Colors.grey,
  );

  TextStyle titleStyle = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  TextStyle excerptStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  Stream<NewsArticle> customArticle(
    NewsArticle newsArticle,
    BuildContext context,
  ) async* {
    if (newsArticle.content.isNotEmpty) {
      yield newsArticle;
    } else {
      NewsArticle cArticle = await newsArticle.load();
      yield cArticle;

      if (Store.shouldTranslate) {
        var translator = SimplyTranslate();
        cArticle.title = await translator.translate(
          cArticle.title,
          Store.languageSetting,
        );
        yield cArticle;
        cArticle.content = await translator.translate(
          cArticle.content,
          Store.languageSetting,
        );
        yield cArticle;
        cArticle.excerpt = await translator.translate(
          cArticle.excerpt,
          Store.languageSetting,
        );
        yield cArticle;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String fullUrl =
        "${publishers[widget.article.publisher]!.homePage}${widget.article.url}";
    String altUrl = "${Store.ladderUrl}/$fullUrl";
    return StreamBuilder<NewsArticle>(
      initialData: widget.article,
      stream: customArticle(widget.article, context),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text(publishers[widget.article.publisher]!.name),
            actions: [
              _shareButton(altUrl: altUrl, fullUrl: fullUrl),
              _openButton(altUrl: altUrl, fullUrl: fullUrl),
            ],
          ),
          body: snapshot.hasData
              ? _successArticle(snapshot)
              : _fallBackArticle(fullUrl),
        );
      },
    );
  }

  FutureBuilder<NewsArticle> _fallBackArticle(String fullUrl) {
    return FutureBuilder(
      future: Smort().fallback(widget.article),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _successArticle(snapshot);
        } else if (snapshot.hasError) {
          return _failArticle(fullUrl);
        }
        return CircularProgressIndicator();
      },
    );
  }

  Center _failArticle(String fallbackUrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 64, right: 64),
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          direction: Axis.vertical,
          children: [
            ListTile(
              title: Text("Error loading article"),
              subtitle: Text("You can try opening the url in your browser"),
            ),
            ListTile(
              leading: Icon(Icons.open_in_browser),
              title: Text("Open in browser"),
              onTap: () {
                launchUrl(Uri.parse(fallbackUrl));
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text("Share"),
              onTap: () {
                Share.shareUri(Uri.parse(fallbackUrl));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _successArticle(AsyncSnapshot<NewsArticle> snapshot) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: ListView(
        children: [
          snapshot.connectionState != ConnectionState.done
              ? LinearProgressIndicator()
              : SizedBox.shrink(),
          textWidget("", snapshot.data!.title, titleStyle),
          textWidget("Author", snapshot.data!.author, metadataStyle),
          textWidget("Published", unixToString(snapshot.data!.publishedAt),
              metadataStyle),
          if (Network.shouldLoadImage(snapshot.data!.thumbnail))
            image(snapshot),
          textWidget("", snapshot.data!.excerpt, excerptStyle),
          HtmlWidget(snapshot.data!.content),
        ],
      ),
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

class _openButton extends StatelessWidget {
  const _openButton({
    super.key,
    required this.altUrl,
    required this.fullUrl,
  });

  final String altUrl;
  final String fullUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        launchUrl(Uri.parse(altUrl));
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

class _shareButton extends StatelessWidget {
  const _shareButton({
    super.key,
    required this.altUrl,
    required this.fullUrl,
  });

  final String altUrl;
  final String fullUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        Share.shareUri(Uri.parse(altUrl));
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
