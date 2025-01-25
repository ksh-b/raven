import 'package:flutter/material.dart';
import 'package:raven/screen/article_feed.dart';
// import 'package:raven/pages/feed_builder.dart';
// import 'package:raven/pages/search.dart';
import 'package:raven/widget/search_delegate.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: const FeedPageDelegate(query: ""),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
