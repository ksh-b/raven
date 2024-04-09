import 'dart:core';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/utils/store.dart';

import 'category_selector.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage>
    with AutomaticKeepAliveClientMixin {
  List<String> newsSources = publishers.keys.toList();
  List<String> filteredNewsSources = [];
  TextEditingController searchController = TextEditingController();
  bool _isSearching = false;
  int? _value = 0;

  @override
  void initState() {
    filteredNewsSources = newsSources;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: searchController,
                onChanged: (value) => searchSubscriptions(),
              )
            : Text('Subscriptions'),
        actions: <Widget>[
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  searchController.text = "";
                  searchSubscriptions();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Wrap(
            spacing: 5.0,
            children: List<Widget>.generate(
              Category.values.length + 1,
              (int index) {
                if (index == 0) {
                  return ChoiceChip(
                    label: Text("all"),
                    selected: _value == index,
                    onSelected: (bool selected) {
                      setState(() {
                        _value = selected ? index : null;
                        filteredNewsSources = newsSources;
                        searchSubscriptions();
                      });
                    },
                  );
                } else {
                  return ChoiceChip(
                    label: Text(
                        Category.values[index - 1].toString().split(".")[1]),
                    selected: _value == index,
                    onSelected: (bool selected) {
                      setState(() {
                        _value = selected ? index : null;
                        searchSubscriptions();
                        filteredNewsSources = filteredNewsSources
                            .where((element) =>
                                publishers[element]?.mainCategory ==
                                Category.values[index - 1])
                            .toList();
                      });
                    },
                  );
                }
              },
            ).toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredNewsSources.length,
              itemBuilder: (context, sourceIndex) {
                var newsSource = filteredNewsSources[sourceIndex];
                var categories = getSelectedCategories(newsSource);
                return ListTile(
                  title: Text(newsSource),
                  leading: CachedNetworkImage(
                    imageUrl: publishers[newsSource]!.iconUrl,
                    progressIndicatorBuilder: (context, url, downloadProgress) {
                      return CircularProgressIndicator(
                        value: downloadProgress.progress,
                      );
                    },
                    height: 24,
                    width: 24,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                  trailing: categories.isEmpty
                      ? SizedBox.shrink()
                      : Icon(Icons.check_circle),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CategorySelector(
                          publishers,
                          newsSource,
                          callback: () {
                            setState(
                              () {
                                categories = getSelectedCategories(newsSource);
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void searchSubscriptions() {
    setState(() {
      filteredNewsSources = newsSources.where((source) {
        return source
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
      }).toList();
    });
  }

  String getSelectedCategories(String newsSource) {
    var categories = Store.selectedSubscriptions
        .where((element) => element.publisher == newsSource)
        .map((e) => e.category != "/" ? e.category.split("/").last : e.category)
        .join(", ");
    return categories;
  }

  @override
  bool get wantKeepAlive => true;
}
