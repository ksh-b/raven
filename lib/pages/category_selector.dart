import 'package:flutter/material.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/model/user_subscription.dart';
import 'package:raven/utils/store.dart';

class CategorySelector extends StatefulWidget {
  final Map<String, Publisher> publishers;
  final String newsSource;
  final VoidCallback callback;

  const CategorySelector(this.publishers, this.newsSource,
      {super.key, required this.callback});

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
    if (input.startsWith("https://") || input.startsWith("http://"))
      return input.split("/").sublist(2).join("/");

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
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.length + 3 + customSubsSize,
                itemBuilder: (context, index) {
                  var subCategoryKey = "All";
                  var subCategoryValue = "/";
                  var userSubscription =
                      UserSubscription(widget.newsSource, subCategoryValue);
                  if (index == 0) {
                    return _buildAllCheckbox(subCategoryKey, userSubscription);
                  }
                  if (index - 1 < snapshot.data!.length) {
                    subCategoryKey = snapshot.data!.keys.toList()[index - 1];
                    subCategoryValue =
                        snapshot.data!.values.toList()[index - 1];
                    userSubscription =
                        UserSubscription(widget.newsSource, subCategoryValue);
                    return _buildCategorySelector(
                        subCategoryKey, userSubscription);
                  } else if (index > snapshot.data!.length &&
                      index < customSubsSize + snapshot.data!.length + 1) {
                    return customCategorySaved(index, snapshot);
                  } else if (index ==
                      (snapshot.data!.length + 1 + customSubsSize)) {
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
                    return SaveButton(
                      selectedSubscriptions: selectedSubscriptions,
                      widget: widget,
                    );
                  }
                },
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
      value: selectedSubscriptions.contains(userSubscription),
      onChanged: selectedSubscriptions
              .where((element) =>
                  element.publisher == userSubscription.publisher &&
                  element.category == "/")
              .isNotEmpty
          ? null
          : (value) {
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
          }),
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
            border: const OutlineInputBorder(),
            hintText: "Custom category",
          ),
          onChanged: (value) {
            setState(() {
              customCategory = value;
            });
          },
        ));
  }

  Flexible _buildCustomTester() {
    return Flexible(
      flex: 1,
      child: FutureBuilder(
        future: widget.publishers[widget.newsSource]
            ?.articles(category: customCategory),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const CircularProgressIndicator();
          if (snapshot.hasError) return const Icon(Icons.cancel);
          if (snapshot.hasData) {
            return snapshot.data!.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      setState(() {
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
                    icon: const Icon(Icons.save_alt))
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
        selectedSubscriptions.add(userSubscription);
      } else {
        selectedSubscriptions.remove(userSubscription);
      }
    });
  }
}

class SaveButton extends StatelessWidget {
  const SaveButton({
    super.key,
    required this.selectedSubscriptions,
    required this.widget,
  });

  final List<UserSubscription> selectedSubscriptions;
  final CategorySelector widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FilledButton(
        onPressed: () {
          Store.selectedSubscriptions = selectedSubscriptions;
          Navigator.of(context).pop();
          widget.callback();
        },
        child: const Text("SAVE"),
      ),
    );
  }
}
