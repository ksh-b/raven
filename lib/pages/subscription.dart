import 'dart:core';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/model/user_subscription.dart';
import 'package:raven/utils/store.dart';

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
                    showDialog(
                      context: context,
                      builder: (context) {
                        return CategoryPopup(publishers, newsSource,
                            callback: () {
                          setState(() {
                            categories = getSelectedCategories(newsSource);
                          });
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

class CategoryPopup extends StatefulWidget {
  final Map<String, Publisher> publishers;
  final String newsSource;
  final VoidCallback callback;

  const CategoryPopup(this.publishers, this.newsSource,
      {super.key, required this.callback});

  @override
  State<CategoryPopup> createState() => _CategoryPopupState();
}

class _CategoryPopupState extends State<CategoryPopup> {
  List<UserSubscription> selectedSubscriptions = []; // List<UserSubscription>
  List customSubscriptions = []; // List<UserSubscription>
  String customCategory = "";
  TextEditingController customCategoryController = TextEditingController();
  Future<Map<String, String>>? future;

  @override
  void initState() {
    setState(() {
      selectedSubscriptions = Store.selectedSubscriptions;
      customSubscriptions = Store.customSubscriptions
          .where((element) => element.publisher == widget.newsSource)
          .toList();
    });
    super.initState();
    future = widget.publishers[widget.newsSource]?.categories;
  }

  String convertString(String input) {
    List<String> parts = input.split('/');
    parts.removeWhere((part) => part.isEmpty);
    List<String> capitalizedParts = parts.map((part) {
      return capitalize(part);
    }).toList();
    String result = capitalizedParts.join('/');
    return result;
  }

  String capitalize(String string) {
    return "${string[0].toUpperCase()}${string.substring(1)}";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Categories",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length + 1,
                    itemBuilder: (context, categoryIndex) {
                      var subCategoryKey = "All";
                      var subCategoryValue = "/";
                      var userSubscription =
                          UserSubscription(widget.newsSource, subCategoryValue);
                      if (categoryIndex == 0) {
                        // All checkbox
                        return CheckboxListTile(
                          title: Text(subCategoryKey),
                          value:
                              selectedSubscriptions.contains(userSubscription),
                          onChanged: (value) {
                            if (value!) {
                              selectedSubscriptions.removeWhere((element) {
                                return element.publisher ==
                                    userSubscription.publisher;
                              });
                            }
                            updateList(value, userSubscription);
                          },
                        );
                      }
                      subCategoryKey =
                          snapshot.data!.keys.toList()[categoryIndex - 1];
                      subCategoryValue =
                          snapshot.data!.values.toList()[categoryIndex - 1];
                      userSubscription =
                          UserSubscription(widget.newsSource, subCategoryValue);
                      // category checkbox
                      return CheckboxListTile(
                        title: Text(subCategoryKey),
                        value: selectedSubscriptions.contains(userSubscription),
                        onChanged: selectedSubscriptions
                                .where((element) =>
                                    element.publisher ==
                                        userSubscription.publisher &&
                                    element.category == "/")
                                .isNotEmpty
                            ? null
                            : (value) {
                                updateList(value, userSubscription);
                              },
                      );
                    },
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: customSubscriptions
                        .where(
                            (element) => element.publisher == widget.newsSource)
                        .length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        secondary: IconButton(
                            icon: const Icon(Icons.delete_forever),
                            onPressed: () {
                              var subscription = customSubscriptions[index];
                              setState(() {
                                customSubscriptions.remove(subscription);
                                selectedSubscriptions.remove(subscription);
                              });
                              var cs = Store.customSubscriptions;
                              cs.remove(subscription);
                              Store.customSubscriptions = cs;
                              var ss = Store.selectedSubscriptions;
                              ss.remove(subscription);
                              Store.selectedSubscriptions = ss;
                            }),
                        title: Text(convertString(
                            (customSubscriptions[index] as UserSubscription)
                                .category)),
                        value: selectedSubscriptions
                            .contains(customSubscriptions[index]),
                        onChanged: (value) {
                          updateList(value, customSubscriptions[index]);
                        },
                      );
                    },
                  ),
                  Flex(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    direction: Axis.horizontal,
                    children: [
                      Flexible(
                          flex: 3,
                          child: TextField(
                            controller: customCategoryController,
                            decoration: const InputDecoration(
                                hintText: "Custom category"),
                            onEditingComplete: () {
                              setState(() {
                                customCategory = customCategoryController.text;
                              });
                            },
                          )),
                      if (customCategory.isEmpty)
                        const Flexible(child: SizedBox.shrink())
                      else
                        Flexible(
                          flex: 1,
                          child: FutureBuilder(
                            future: widget.publishers[widget.newsSource]
                                ?.articles(category: customCategory),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return snapshot.data!.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          setState(() {
                                            customSubscriptions
                                                .add(UserSubscription(
                                              widget.newsSource,
                                              customCategory,
                                            ));
                                          });
                                          Store.customSubscriptions += [
                                            UserSubscription(
                                              widget.newsSource,
                                              customCategory,
                                            )
                                          ];
                                        },
                                        icon: const Icon(Icons.save_alt))
                                    : const Icon(Icons.cancel);
                              } else if (snapshot.hasError) {
                                const Icon(Icons.cancel);
                              }
                              return const CircularProgressIndicator();
                            },
                          ),
                        )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilledButton(
                      onPressed: () {
                        Store.selectedSubscriptions = selectedSubscriptions;
                        Navigator.of(context).pop();
                        widget.callback();
                      },
                      child: const Text("SAVE"),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(snapshot.error.toString()),
            );
          }
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Loading"),
          );
        },
      ),
    );
  }

  void updateList(bool? value, UserSubscription userSubscription) {
    setState(() {
      if (value!) {
        selectedSubscriptions.add(userSubscription);
      } else {
        selectedSubscriptions.remove(userSubscription);
      }
    });
  }
}
