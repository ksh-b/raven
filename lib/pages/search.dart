import 'package:flutter/material.dart';
import 'package:raven/model/trends.dart';
import 'package:raven/pages/feed_builder.dart';
import 'package:raven/utils/store.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage(this.query, {super.key});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FeedPageBuilder(query: widget.query);
  }
}

class MySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
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
    return SearchResultsPage(query);
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
          return Center(
            child: const CircularProgressIndicator(),
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
