import 'package:flutter/material.dart';
import 'package:raven/repository/trends.dart';
import 'package:raven/screen/article_feed.dart';

import '../repository/store.dart';

class MySearchDelegate extends SearchDelegate<String> {
  int page = 1;
  List<Widget> tiles = [];
  String currentQuery = "";

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          page = 1;
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FeedPageDelegate(query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: trends[Store.trendsProviderSetting]?.topics,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView(
            children: snapshot.data!
                .map((e) => ListTile(
                      leading: const Icon(Icons.trending_up_rounded),
                      title: Text(e),
                      onTap: () {
                        query = e;
                        showResults(context);
                      },
                    ))
                .toList(),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else {
          return const Center(child: Text("No data"));
        }
      },
    );
  }
}
