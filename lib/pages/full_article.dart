import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whapp/model/article.dart';
import 'package:whapp/utils/network.dart';
import 'package:whapp/utils/store.dart';

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

  TextStyle excerptStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey[700],
  );

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<NewsArticle?>(
      initialData: widget.article,
      future: widget.article.publisher.article(widget.article),
      builder: (context, snapshot) {
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
          body: snapshot.connectionState == ConnectionState.done
              ? snapshot.hasData
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(
                        children: [
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
                  : const Center(child: Text("Error loading data"))
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Padding image(AsyncSnapshot<NewsArticle?> snapshot) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CachedNetworkImage(
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
    return value.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            child: Text(
              label.isNotEmpty ? '$label: $value' : value,
              style: style,
            ),
          )
        : SizedBox.shrink();
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
            return Network.shouldLoadImage(extensionContext.attributes[src]!)
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
