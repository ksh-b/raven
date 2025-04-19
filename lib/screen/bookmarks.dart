import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:klaws/model/article.dart';
import 'package:raven/repository/preferences/bookmarks.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/string.dart';
import 'package:raven/widget/article_card.dart';
import 'package:raven/widget/blank_page_message.dart';

class BookmarksPage extends StatefulWidget {
  final String? query;
  final bool bookmarks;

  const BookmarksPage({super.key, this.query, this.bookmarks = false});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookmarks"),
      ),
      body: ValueListenableBuilder(
        valueListenable: BookmarkedArticles.bookmarks.listenable(),
        builder: (BuildContext context, box, Widget? child) {
          if (BookmarkedArticles.bookmarks.isNotEmpty) {
            return ListView.separated(
              itemCount: BookmarkedArticles.bookmarks.keys.length,
              itemBuilder: (context, index) {
                Article article = BookmarkedArticles.bookmarks.values.toList()[index];
                return ArticleCard(
                  article,
                  showBookmarkIcon: false,
                  showSaveIcon: true,
                  deleteBookmarked: true,
                );
              },
              separatorBuilder: (BuildContext context, int index) => Divider(),
            );
          }
          return const BlankPageMessage(
            "No articles bookmarked",
          );
        },
      ),
    );
  }
}

// class FeedCard extends StatelessWidget {
//   const FeedCard({
//     super.key,
//     required this.article,
//   });
//
//   final Article article;
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(8.0),
//         child: InkWell(
//           child: Flex(
//             direction: Axis.vertical,
//             children: [
//               ContentPref.shouldLoadImages
//                   ? Stack(
//                       children: [
//                         ArticleThumbnail(article: article),
//                         ArticleTags(article: article),
//                       ],
//                     )
//                   : const SizedBox.shrink(),
//               ListTile(
//                 title: SelectableText(article.title),
//                 leading: ArticlePublisherIcon(article: article),
//                 subtitle: article.publishedAt != -1
//                     ? SelectableText(
//                         unixToString(article.publishedAt),
//                       )
//                     : const SizedBox.shrink(),
//               ),
//             ],
//           ),
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => ArticlePage(
//                   article,
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

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
