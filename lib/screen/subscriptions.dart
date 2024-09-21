import 'dart:core';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:raven/model/category.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/provider/category_search.dart';
import 'package:raven/repository/store.dart';
import 'package:raven/screen/category_selector.dart';

import '../repository/publishers.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage>
    with AutomaticKeepAliveClientMixin {
  TextEditingController searchController = TextEditingController();
  String _value = "all";

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<CategorySearchProvider>(
      builder: (context, search, child) {
        return Scaffold(
          appBar: AppBar(
            title: search.isInProgress
                ? TextField(
                    controller: searchController,
                    onChanged: (value) {
                      search.searchPublishersByName(value);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Search subscriptions",
                    ),
                  )
                : const Text('Subscriptions'),
            actions: <Widget>[
              IconButton(
                icon: Icon(search.isInProgress ? Icons.close : Icons.search),
                onPressed: () {
                  search.isInProgress = !search.isInProgress;
                  if (!search.isInProgress) {
                    searchController.text = "";
                    search.searchPublishersByName(searchController.text);
                  }
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
                    _value = selected ?? "all";
                    search.searchPublishersByName(searchController.text);
                    search.searchPublishersByCategory(_value);
                  },
                  items: (["all"] + Category.values.map((e) => e.name).toList())
                      .map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Category",
                  ),
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: Store.subscriptions.listenable(),
                  builder: (BuildContext context, value, Widget? child) {
                    return ListView.builder(
                      itemCount: search.filteredPublishers.length,
                      itemBuilder: (context, sourceIndex) {
                        var newsSource = search.filteredPublishers[sourceIndex];
                        var categories = getSelectedCategories(newsSource);
                        return ListTile(
                          title: Text(newsSource),
                          leading: CachedNetworkImage(
                            imageUrl: Publisher.fromString(newsSource).iconUrl,
                            progressIndicatorBuilder: (
                              context,
                              url,
                              downloadProgress,
                            ) {
                              return CircularProgressIndicator(
                                value: downloadProgress.progress,
                              );
                            },
                            height: 24,
                            width: 24,
                            errorWidget: (context, url, error) => CircleAvatar(
                              child: Text(
                                newsSource.characters.first,
                              ),
                            ),
                          ),
                          trailing: categories.isEmpty
                              ? const SizedBox.shrink()
                              : const Icon(Icons.check_circle),
                          onTap: () {
                            Navigator.of(context)
                                .push(
                              MaterialPageRoute(
                                builder: (context) => CategorySelector(
                                  publishers,
                                  newsSource,
                                ),
                              ),
                            )
                                .whenComplete(() {
                              categories = getSelectedCategories(newsSource);
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String getSelectedCategories(String newsSource) {
    var categories = Store.selectedSubscriptions
        .where((element) => element.publisher == newsSource)
        .map((e) {
      var cat = e.categoryPath.split("/").where((i) => i.isNotEmpty);
      return e.categoryPath != "/"
          ? cat.isNotEmpty
              ? cat.last
              : ""
          : e.categoryPath;
    }).join(", ");
    return categories;
  }

  @override
  bool get wantKeepAlive => true;
}
