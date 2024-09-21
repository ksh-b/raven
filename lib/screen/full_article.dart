import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/repository/store.dart';
import 'package:raven/utils/time.dart';
import 'package:raven/widget/html_widget.dart';
import 'package:raven/widget/options_popup.dart';
import 'package:raven/widget/translated_text.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

TextStyle titleStyle = const TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

TextStyle excerptStyle = const TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

class ArticlePage extends StatefulWidget {
  final bool shouldLoad;
  final Article article;

  const ArticlePage(this.article, {super.key, this.shouldLoad = true});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  @override
  Widget build(BuildContext context) {
    final String fullUrl = widget.article.url;
    return Scaffold(
      appBar: AppBar(
        title: SelectableText(widget.article.publisher),
        actions: [
          ShareButton(fullUrl: fullUrl),
          OpenUrlButton(fullUrl: fullUrl),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FutureBuilder(
            initialData: widget.article,
            future: Publisher.fromString(widget.article.publisher)
                .article(widget.article),
            builder: (context, response) {
              if (response.hasData && widget.shouldLoad) {
                return FullArticle(response: response);
              } else {
                return LoadingArticle(widget: widget);
              }
            }),
      ),
    );
  }
}

class LoadingArticle extends StatelessWidget {
  const LoadingArticle({
    super.key,
    required this.widget,
  });

  final ArticlePage widget;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Progress
        if (widget.shouldLoad) const LinearProgressIndicator(),
        const SizedBox(height: 8),

        // Title
        SelectableText(
          widget.article.title,
          style: titleStyle,
        ),
        const SizedBox(height: 12),

        // Excerpt
        SelectableText(
          widget.article.excerpt,
          style: excerptStyle,
        ),
        const SizedBox(height: 12),

        // Publisher details
        if (widget.article.publishedAt != -1)
          SelectableText(unixToString(widget.article.publishedAt)),
        const SizedBox(height: 8),

        if (widget.article.author.isNotEmpty)
          SelectableText("By ${widget.article.author}"),

        // Thumbnail
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(imageUrl: widget.article.thumbnail),
        ),
        const SizedBox(height: 12),

        // Content
        HtmlWidget(widget.article.content)
      ],
    );
  }
}

class FullArticle extends StatelessWidget {
  const FullArticle({
    super.key,
    required this.response,
  });

  final AsyncSnapshot<Article> response;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Title
        TranslatedText(
          response.data!.title,
          style: titleStyle,
        ),
        const SizedBox(height: 12),

        // Excerpt
        TranslatedText(
          response.data!.excerpt,
          style: excerptStyle,
        ),
        const SizedBox(height: 12),

        // Publisher details
        if (response.data!.publishedAt != -1)
          SelectableText(unixToString(response.data!.publishedAt)),
        const SizedBox(height: 8),

        if (response.data!.author.isNotEmpty)
          SelectableText("By ${response.data!.author}"),

        // Thumbnail
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(imageUrl: response.data!.thumbnail),
        ),
        const SizedBox(height: 12),

        // Content
        Store.shouldTranslate
            ? TranslatedText(response.data?.content ?? "")
            : HtmlWidget(response.data?.content ?? "")
      ],
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
        icon: const Icon(Icons.open_in_browser),
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
        icon: const Icon(Icons.share),
        onPressed: () {
          Share.shareUri(Uri.parse(fullUrl));
        },
      ),
    );
  }
}
