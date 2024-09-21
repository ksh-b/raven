import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:raven/utils/network.dart';
import 'package:url_launcher/url_launcher.dart';

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
            : const SizedBox.shrink();
      },
    );
  }
}
