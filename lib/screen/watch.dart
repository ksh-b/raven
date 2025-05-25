import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raven/model/watch_item_history.dart';
import 'package:raven/repository/preferences/subscriptions.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/time.dart';
import 'package:raven/widget/html_widget.dart';
import 'package:klaws/provider/watch_extractor.dart';
import 'package:url_launcher/url_launcher.dart';

class WatchPage extends StatefulWidget {
  const WatchPage({super.key});

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  @override
  void initState() {
    super.initState();
    UserSubscriptionPref.getAllWatchSubs().forEach((history) async {
      var content = await WatchExtractor()
          .extractWatchContent(history.watch, history.itemsHistory.last.url, dio());
      if (content != null) {
        UserSubscriptionPref.upsertWatchItem(history.watch, content);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: UserSubscriptionPref.getAllWatchSubs()
            .map((e) => WatchCard(watchItemHistory: e))
            .toList(),
      ),
    );
  }
}

class WatchCard extends StatefulWidget {
  final WatchItemHistory watchItemHistory;

  const WatchCard({required this.watchItemHistory, super.key});

  @override
  State<WatchCard> createState() => _WatchCardState();
}

class _WatchCardState extends State<WatchCard> {
  @override
  Widget build(BuildContext context) {
    var latestItem = widget.watchItemHistory.itemsHistory.last;
    return Card(
      margin: EdgeInsets.all(16),
      child: InkWell(
        child: Flex(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          direction: Axis.vertical,
          children: [
            ListTile(
              title: latestItem.title.isNotEmpty ? Text(latestItem.title) : null,
              subtitle: latestItem.subtitle.isNotEmpty
                  ? Text(latestItem.subtitle)
                  : null,
              leading:
                  (latestItem.leading.top + latestItem.leading.bottom).isNotEmpty
                      ? Flex(
                          direction: Axis.vertical,
                          children: [
                            latestItem.leading.top.isNotEmpty?
                            isImageUrl(latestItem.leading.top)
                                ? Image(url: latestItem.leading.top)
                                : Text(latestItem.leading.top):
                            SizedBox.shrink(),
                            latestItem.leading.bottom.isNotEmpty?
                            isImageUrl(latestItem.leading.bottom)
                                ? Image(url: latestItem.leading.bottom)
                                : Text(latestItem.leading.bottom):
                            SizedBox.shrink(),
                          ],
                        )
                      : null,
              trailing: (latestItem.trailing.top + latestItem.trailing.bottom)
                      .isNotEmpty
                  ? Flex(
                      direction: Axis.vertical,
                      children: [
                        latestItem.trailing.top.isNotEmpty?
                        isImageUrl(latestItem.trailing.top)
                            ? Image(url: latestItem.trailing.top)
                            : Text(latestItem.trailing.top):
                        SizedBox.shrink(),
                        latestItem.trailing.bottom.isNotEmpty?
                        isImageUrl(latestItem.trailing.bottom)
                            ? Image(url: latestItem.trailing.bottom)
                            : Text(latestItem.trailing.bottom):
                        SizedBox.shrink(),
                      ],
                    )
                  : null,
            ),
            Divider(),
            Flex(
              direction: Axis.vertical,
              children: latestItem.notes.map(
                (e) {
                  return HtmlWidget(e);
                },
              ).toList(),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "${widget.watchItemHistory.watch.watch.name} ⸱ ${unixToString(widget.watchItemHistory.lastUpdate)}",
              ),
            ),
          ],
        ),
        onTap: () {
          if (latestItem.url.isNotEmpty) {
            launchUrl(Uri.parse(latestItem.url));
          }
        },
      ),
    );
  }

  bool isImageUrl(String url) {
    RegExp urlRegex = RegExp(r'https\S*(?:jpg|jpeg|png|webp|gif|svg)');
    return urlRegex.hasMatch(url);
  }
}

class Image extends StatelessWidget {
  final String url;

  const Image({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      child: url.endsWith("svg")
          ? SvgPicture.network(url)
          : CachedNetworkImage(imageUrl: url),
      size: Size(30, 30),
    );
  }
}
