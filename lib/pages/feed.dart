import 'package:flutter/material.dart';
import 'package:raven/pages/feed_builder.dart';
import 'package:raven/pages/search.dart';

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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('What\'s happening?'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: MySearchDelegate(),
                );
              },
            ),
          ],
        ),
        body: FeedPageBuilder(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
