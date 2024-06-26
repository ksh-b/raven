import 'package:flutter/material.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/model/user_subscription.dart';
import 'package:raven/utils/store.dart';

class CategorySelector extends StatefulWidget {
  final Map<String, Publisher> publishers;
  final String newsSource;

  const CategorySelector(this.publishers, this.newsSource, {super.key});

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
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
    if (input.startsWith("https://") || input.startsWith("http://")) {
      return input.split("/").sublist(2).join("/").replaceAll("www.", "");
    }

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
    int customSubsSize = customSubscriptions
        .where((element) => element.publisher == widget.newsSource)
        .length;
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.newsSource} categories"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.publishers[widget.newsSource]!.hasSearchSupport
                ? ActionChip(
                    label: Text("Has search support"),
                    avatar: Icon(Icons.search_rounded),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  )
                : SizedBox.shrink(),
            FutureBuilder(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var pubCats = snapshot.data;
                  return Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length + customSubsSize + 2,
                      itemBuilder: (context, index) {
                        var subCategoryKey = "Default";
                        var subCategoryValue = "/";
                        var userSubscription = UserSubscription(
                            widget.newsSource, subCategoryValue);

                        // all checkbox
                        if (index == 0) {
                          var mainCat =
                              publishers[widget.newsSource]!.mainCategory;
                          if (mainCat == Category.custom) {
                            return SizedBox.shrink();
                          }
                          return _buildAllCheckbox(
                              subCategoryKey, userSubscription);
                        }

                        // publisher categories checkbox
                        if (index - 1 < pubCats!.length) {
                          subCategoryKey = pubCats.keys.toList()[index - 1];
                          subCategoryValue = pubCats.values.toList()[index - 1];
                          userSubscription = UserSubscription(
                            widget.newsSource,
                            subCategoryValue,
                          );
                          return _buildCategorySelector(
                            subCategoryKey,
                            userSubscription,
                          );
                        }

                        // custom categories saved by user
                        else if (index > pubCats.length &&
                            index < customSubsSize + pubCats.length + 1) {
                          return customCategorySaved(index, snapshot);
                        }

                        // custom categories selector
                        else if (index ==
                            (pubCats.length + 1 + customSubsSize)) {
                          return Flex(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            direction: Axis.horizontal,
                            children: [
                              _buildCustomSourceSelector(),
                              if (customCategory.isEmpty)
                                const Flexible(child: SizedBox.shrink())
                              else
                                _buildCustomTester()
                            ],
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(snapshot.error.toString()),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  CheckboxListTile _buildAllCheckbox(
      String subCategoryKey, UserSubscription userSubscription) {
    return CheckboxListTile(
      title: Text(subCategoryKey),
      value: selectedSubscriptions.contains(userSubscription),
      onChanged: (value) {
        if (value!) {
          selectedSubscriptions.removeWhere((element) {
            return element.publisher == userSubscription.publisher;
          });
        }
        updateList(value, userSubscription);
      },
    );
  }

  CheckboxListTile _buildCategorySelector(
      String subCategoryKey, UserSubscription userSubscription) {
    return CheckboxListTile(
      title: Text(subCategoryKey),
      subtitle: Text(userSubscription.category),
      value: selectedSubscriptions.contains(userSubscription),
      onChanged: (value) {
        updateList(value, userSubscription);
      },
    );
  }

  CheckboxListTile customCategorySaved(
      int index, AsyncSnapshot<Map<String, String>> snapshot) {
    return CheckboxListTile(
      secondary: IconButton(
        icon: const Icon(Icons.delete_forever),
        onPressed: () {
          var subscription =
              customSubscriptions[index - (snapshot.data!.length + 1)];
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
        },
      ),
      title: Text(convertString(
          (customSubscriptions[index - (snapshot.data!.length + 1)]
                  as UserSubscription)
              .category)),
      value: selectedSubscriptions
          .contains(customSubscriptions[index - (snapshot.data!.length + 1)]),
      onChanged: (value) {
        updateList(
            value, customSubscriptions[index - (snapshot.data!.length + 1)]);
      },
    );
  }

  Widget _buildCustomSourceSelector() {
    return Flexible(
      flex: 3,
      fit: FlexFit.tight,
      child: TextField(
        controller: customCategoryController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Custom URL",
        ),
        onChanged: (value) {
          setState(() {
            customCategory = value;
          });
        },
      ),
    );
  }

  Flexible _buildCustomTester() {
    return Flexible(
      flex: 1,
      child: FutureBuilder(
        future: widget.publishers[widget.newsSource]
            ?.articles(category: customCategory),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) return const Icon(Icons.cancel);
          if (customCategoryController.text.isEmpty) {
            return const SizedBox.shrink();
          }
          if (snapshot.hasData) {
            return snapshot.data!.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        customCategoryController.text = "";
                        customSubscriptions.add(UserSubscription(
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
                    icon: const Icon(Icons.save_alt),
                  )
                : const Icon(Icons.cancel);
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  void updateList(bool? value, UserSubscription userSubscription) {
    setState(() {
      if (value!) {
        Store.selectedSubscriptions = selectedSubscriptions
          ..add(userSubscription);
      } else {
        Store.selectedSubscriptions = selectedSubscriptions
          ..remove(userSubscription);
      }
    });
  }
}
