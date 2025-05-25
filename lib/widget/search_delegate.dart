import 'package:flutter/material.dart';
import 'package:raven/repository/preferences/content.dart';
import 'package:raven/repository/search_suggestions.dart';
import 'package:raven/repository/trends.dart';
import 'package:raven/screen/article_feed.dart';

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

  Future<List<String>> combined() async {
    var topics = await trends[ContentPref.trendsProvider]?.topics;
    var suggestions = await searchSuggestions[ContentPref.searchSuggestionsProvider]?.suggestions(query);
    topics = (topics??List<String>.empty());
    suggestions = (suggestions??List<String>.empty());
    topics = topics.where((topic) {
      return query.isEmpty
          ? true
          :topic.toString().toLowerCase().contains(query.toLowerCase());
    }).toList();
    return topics+suggestions;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: combined(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView(
            children: snapshot.data!
                .map(
                  (e) => ListTile(
                    leading: const Icon(Icons.trending_up_rounded),
                    title: Text(e),
                    onTap: () {
                      query = e;
                      showResults(context);
                    },
                  ),
                )
                .toList(),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
