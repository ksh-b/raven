import 'dart:core';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:whapp/model/publisher.dart';
import 'package:whapp/model/user_subscription.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> with AutomaticKeepAliveClientMixin {
  List<String> newsSources = publishers.keys.toList();
  List<String> filteredNewsSources = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    filteredNewsSources = newsSources;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  filteredNewsSources = newsSources
                      .where((source) =>
                          source.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Search News Sources',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredNewsSources.length,
              itemBuilder: (context, sourceIndex) {
                var newsSource = filteredNewsSources[sourceIndex];
                var categories = (Hive.box("subscriptions").get("selected"))
                    .where((element) => element.publisher==newsSource)
                    .map((e) => e.category)
                    .join(", ");
                return ListTile(
                  title: Text(newsSource),
                  subtitle: categories.isEmpty? null:Text(categories),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return CategoryPopup(publishers, newsSource);
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

  @override
  bool get wantKeepAlive => true;
}

class CategoryPopup extends StatefulWidget {
  final Map<String, Publisher> publishers;
  final String newsSource;

  const CategoryPopup(this.publishers, this.newsSource, {super.key});

  @override
  State<CategoryPopup> createState() => _CategoryPopupState();
}

class _CategoryPopupState extends State<CategoryPopup> {
  List selectedSources = []; // List<UserSubscription>
  List customSources = []; // List<UserSubscription>
  String customCategory = "";
  TextEditingController customCategoryController = TextEditingController();

  @override
  void initState() {
    setState(() {
      selectedSources = Hive.box("subscriptions").get("selected") ??
          List<UserSubscription>.empty(growable: true);
      customSources = Hive.box("subscriptions").get("custom") ??
          List<UserSubscription>.empty(growable: true);
    });
    super.initState();
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
        future: widget.publishers[widget.newsSource]?.categories,
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                          value: selectedSources.contains(userSubscription),
                          onChanged: (value) {
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
                        value: selectedSources.contains(userSubscription),
                        onChanged: selectedSources
                                .where((element) => element.category == "/")
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
                    itemCount: customSources.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        secondary: IconButton(icon: const Icon(Icons.delete_forever), onPressed: () {
                          var subscription = customSources[index];
                          setState(() {
                            customSources.remove(subscription);
                            selectedSources.remove(subscription);
                          });

                          Hive.box("subscriptions").put("custom", customSources);
                          Hive.box("subscriptions").put("selected", selectedSources);
                        }),
                        title: Text(convertString((customSources[index] as UserSubscription).category)),
                        value: selectedSources.contains(customSources[index]),
                        onChanged: (value) {
                          updateList(value, customSources[index]);
                        },
                      );
                  },),
                  Flex(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    direction: Axis.horizontal,
                    children: [
                      Flexible(
                          flex: 3,
                          child: TextField(
                            controller: customCategoryController,
                            decoration:
                                const InputDecoration(hintText: "Custom category"),
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
                                            customSources.add(UserSubscription(
                                              widget.newsSource,
                                              customCategory,
                                            ));
                                          });
                                          Hive.box("subscriptions").put(
                                            "custom",
                                            customSources,
                                          );
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
                        Hive.box("subscriptions")
                            .put("selected", selectedSources);
                        Navigator.of(context).pop();
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
        selectedSources.add(userSubscription);
      } else {
        selectedSources.remove(userSubscription);
      }
    });
  }
}
