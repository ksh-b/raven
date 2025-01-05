import 'dart:core';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/model/watch.dart';
import 'package:raven/provider/category_search.dart';
import 'package:raven/provider/watch_search.dart';
import 'package:raven/repository/preferences/content.dart';
import 'package:raven/repository/preferences/subscriptions.dart';
import 'package:raven/screen/category_selector.dart';
import 'package:raven/screen/watch_sources.dart';

import '../repository/publishers.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<FeedSourceSearchProvider>(
      builder: (context, search, child) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(tabs: [
                Tab(icon: Text("Feeds")),
                Tab(icon: Text("Watches")),
              ]),
            ),
            body: TabBarView(children: [
              FeedSelector(),
              WatchSelector(),
            ]),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class WatchSelector extends StatefulWidget {
  const WatchSelector({super.key});

  @override
  State<WatchSelector> createState() => _WatchSelectorState();
}

class _WatchSelectorState extends State<WatchSelector> {
  String _value = "All";
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        // search.isInProgress
        //     ? TextField(
        //         controller: searchController,
        //         onChanged: (value) {
        //           search.searchPublishersByName(value);
        //         },
        //         decoration: const InputDecoration(
        //           border: OutlineInputBorder(),
        //           hintText: "Search subscriptions",
        //         ),
        //       )
        //     :
        const Text('Subscriptions'),
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(search.isInProgress ? Icons.close : Icons.search),
        //     onPressed: () {
        //       search.isInProgress = !search.isInProgress;
        //       if (!search.isInProgress) {
        //         searchController.text = "";
        //         search.searchPublishersByName(searchController.text);
        //       }
        //     },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            // child: DropdownButtonFormField(
            //   value: _value,
            //   onChanged: (selected) {
            //     _value = selected ?? "All";
            //     search.searchPublishersByName(searchController.text);
            //     search.searchPublishersByCategory(_value);
            //   },
            //   items: (["All"] +
            //           (publishers.values
            //                   .map((value) => value.siteCategories))
            //               .expand((i) => i)
            //               .toList())
            //       .toSet()
            //       .map((item) {
            //     return DropdownMenuItem(
            //       value: item,
            //       child: Text(item),
            //     );
            //   }).toList(),
            //   decoration: const InputDecoration(
            //     border: OutlineInputBorder(),
            //     labelText: "Category",
            //   ),
            // ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: ContentPref.watchSources.length,
              itemBuilder: (context, sourceIndex) {
                Watch source = ContentPref.watchSources[sourceIndex];
                return ListTile(
                  title: Text(source.watch.name),
                  leading: ClipOval(
                    child: Icon(Icons.watch),
                  ),
                  subtitle: Text(source.watch.description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WatchSources(watch: source)),
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

  String getSelectedCategories(Source source) {
    var categories = UserSubscriptionPref.selectedSubscriptions
        .where((saved) =>
            saved.source.id == source.id ||
            source.otherVersions.contains(saved.source))
        .map((e) {
      var cat = e.categoryLabel.split("/").where((i) => i.isNotEmpty);
      return e.categoryLabel != "/"
          ? cat.isNotEmpty
              ? cat.last
              : ""
          : e.categoryLabel;
    }).toList()
      ..sort();
    return categories.join(", ");
  }
}

class FeedSelector extends StatefulWidget {
  const FeedSelector({super.key});

  @override
  State<FeedSelector> createState() => _FeedSelectorState();
}

class _FeedSelectorState extends State<FeedSelector> {
  String _value = "All";
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedSourceSearchProvider>(
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
                    _value = selected ?? "All";
                    search.searchPublishersByName(searchController.text);
                    search.searchPublishersByCategory(_value);
                  },
                  items: (["All"] +
                          (publishers.values
                                  .map((value) => value.siteCategories))
                              .expand((i) => i)
                              .toList())
                      .toSet()
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
                  valueListenable: UserSubscriptionPref.feedSubscriptions.listenable(),
                  builder: (BuildContext context, value, Widget? child) {
                    return ListView.builder(
                      itemCount: search.filteredPublishers.length,
                      itemBuilder: (context, sourceIndex) {
                        Source source = search.filteredPublishers[sourceIndex];
                        var categories = getSelectedCategories(source);
                        return ListTile(
                          title: Text(source.name),
                          leading: ClipOval(
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: source.iconUrl,
                              progressIndicatorBuilder: (
                                context,
                                url,
                                downloadProgress,
                              ) {
                                return CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                );
                              },
                              height: 40,
                              width: 40,
                              errorWidget: (context, url, error) =>
                                  CircleAvatar(
                                child: Text(
                                  source.name.characters.first,
                                ),
                              ),
                            ),
                          ),
                          subtitle: categories.isNotEmpty
                              ? Text(
                                  categories,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : SizedBox.shrink(),
                          trailing: categories.isEmpty
                              ? const SizedBox.shrink()
                              : const Icon(Icons.check_circle),
                          onTap: () {
                            Navigator.of(context)
                                .push(
                              MaterialPageRoute(
                                builder: (context) => CategorySelector(
                                  publishers,
                                  source,
                                ),
                              ),
                            )
                                .whenComplete(() {
                              categories = getSelectedCategories(source);
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

  String getSelectedCategories(Source source) {
    var categories = UserSubscriptionPref.selectedSubscriptions
        .where((saved) =>
            saved.source.id == source.id ||
            source.otherVersions.contains(saved.source))
        .map((e) {
      var cat = e.categoryLabel.split("/").where((i) => i.isNotEmpty);
      return e.categoryLabel != "/"
          ? cat.isNotEmpty
              ? cat.last
              : ""
          : e.categoryLabel;
    }).toList()
      ..sort();
    return categories.join(", ");
  }
}
