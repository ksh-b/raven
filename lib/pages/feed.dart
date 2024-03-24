import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:raven/brain/article_provider.dart';
import 'package:raven/model/article.dart';
import 'package:raven/pages/feed_builder.dart';
import 'package:raven/pages/search.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with AutomaticKeepAliveClientMixin {
  List<NewsArticle> newsArticles = [];
  ArticleProvider articleProvider = ArticleProvider();
  TextEditingController searchController = TextEditingController();
  HashMap<int, dynamic> subscriptionPage = HashMap();

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
        body: FutureBuilder(
          future: articleProvider.loadPage(1, query: null),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FeedPageBuilder(null, snapshot.data!);
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            } else {
              return Center(child: Text("No data"));
            }
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}