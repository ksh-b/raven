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
  String _value = "all";

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
            : const Text('Subscriptions'),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField(
              value: _value,
              onChanged: (selected) {
                setState(() {
                  _value = selected!;
                  searchSubscriptions();
                  if(selected == "all") {
                    filteredNewsSources = newsSources;
                  }
                  else {
                    filteredNewsSources = newsSources
                        .where((element) => publishers[element]?.mainCategory.name == selected)
                        .toList();
                  }
                });
              },
              items: (["all"] + Category.values.map((e) => e.name).toList()).map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Category"
              ),
            ),
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
                        CircleAvatar(child: Text(newsSource.characters.first),),
                  ),
                  trailing: categories.isEmpty
                      ? const SizedBox.shrink()
                      : const Icon(Icons.check_circle),
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
        .map((e) {
          var cat = e.category.split("/").where((i) => i.isNotEmpty);
          return e.category != "/"
            ? cat.isNotEmpty?cat.last:""
            : e.category;
        })
        .join(", ");
    return categories;
  }

  @override
  bool get wantKeepAlive => true;
}
