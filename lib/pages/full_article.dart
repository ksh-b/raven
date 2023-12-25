import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whapp/model/article.dart';

class ArticlePage extends StatefulWidget {
  final NewsArticle article;

  const ArticlePage({super.key, required this.article});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<NewsArticle?>(
        initialData: widget.article,
        future: widget.article.publisher.article(widget.article.url),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    snapshot.data!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Author: ${snapshot.data!.author}',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Published: ${snapshot.data!.publishedAt.value}',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (snapshot.data!.thumbnail.isNotEmpty &&
                      snapshot.data!.thumbnail.startsWith("https"))
                    CachedNetworkImage(
                      imageUrl: snapshot.data!.thumbnail,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) {
                        return CircularProgressIndicator(
                            value: downloadProgress.progress);
                      },
                      errorWidget: (context, url, error) {
                        return const Icon(Icons.error);
                      },
                    ),
                  const SizedBox(height: 16),
                  Text(
                    snapshot.data!.excerpt,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  HtmlWidget(
                    snapshot.data!.content,
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            throw snapshot.error!;
          }
          return const Center(child: CircularProgressIndicator());
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
            return CachedNetworkImage(
              imageUrl: extensionContext.attributes[src]!,
              progressIndicatorBuilder: (context, url, downloadProgress) {
                return CircularProgressIndicator(
                  value: downloadProgress.progress,
                );
              },
              errorWidget: (context, url, error) {
                return const Icon(Icons.error);
              },
            );
          },
        ),
      ],
    );
  }
}
