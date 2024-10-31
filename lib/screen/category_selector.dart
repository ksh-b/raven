import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/model/user_subscription.dart';
import 'package:raven/repository/preferences/subscriptions.dart';
import 'package:raven/repository/store.dart';
import 'package:raven/widget/custom_category_textbox.dart';

class CategorySelector extends StatefulWidget {
  final Map<String, Publisher> publishers;
  final String newsSource;

  const CategorySelector(this.publishers, this.newsSource, {super.key});

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  ValueNotifier<String> customCategory = ValueNotifier<String>("");
  TextEditingController customCategoryController = TextEditingController();
  Map<String, String> categories = {};
  List<UserSubscription> availableSubscriptions = [];
  late Future<Map<String, String>> futureCategories;

  @override
  void initState() {
    super.initState();
    futureCategories = Publisher.fromString(widget.newsSource).categories;
  }

  @override
  Widget build(BuildContext context) {
    Set<UserSubscription> defaultSubscription = {
      UserSubscription(widget.newsSource, "Default", "/")
    };

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.newsSource} categories"),
      ),
      body: ValueListenableBuilder(
        valueListenable: SubscriptionPref.subscriptions.listenable(),
        builder: (context, value, child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.publishers[widget.newsSource]!.hasSearchSupport
                    ? ActionChip(
                        label: const Text("Has search support"),
                        avatar: const Icon(Icons.search_rounded),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      )
                    : const SizedBox.shrink(),
                Flexible(
                  child: FutureBuilder<Map<String, String>>(
                      future: futureCategories,
                      builder: (context, categories) {
                        if (categories.hasError ||
                            (categories.hasData && categories.data!.isEmpty)) {
                          return const SizedBox.shrink();
                        } else if (categories.hasData &&
                            categories.data!.isNotEmpty) {
                          categories.data!.forEach((key, value) {
                            availableSubscriptions.add(
                              UserSubscription(widget.newsSource, key, value),
                            );
                          });
                          List<UserSubscription> allSubscriptions =
                              defaultSubscription
                                  .union(availableSubscriptions.toSet())
                                  .union(SubscriptionPref.customSubscriptions.toSet())
                                  .union(SubscriptionPref.selectedSubscriptions.toSet())
                                  .where((element) =>
                                      element.publisher == widget.newsSource)
                                  .toList();
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: allSubscriptions.length + 2,
                            itemBuilder: (context, index) {
                              if (index < allSubscriptions.length) {
                                var subscription = allSubscriptions[index];
                                return ListTile(
                                  title: Text(subscription.categoryLabel),
                                  subtitle: Text(subscription.categoryPath),
                                  trailing: Flex(
                                    mainAxisSize: MainAxisSize.min,
                                    direction: Axis.horizontal,
                                    children: [
                                      if (subscription.isCustom)
                                        DeleteCustomCategory(
                                          subscription: subscription,
                                        ),
                                      Checkbox(
                                        value: SubscriptionPref.selectedSubscriptions
                                            .contains(subscription),
                                        onChanged: (value) {
                                          updateSubscription(
                                            value,
                                            subscription,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }

                              // custom categories selector
                              else if (index == (allSubscriptions.length + 1) &&
                                  Publisher.fromString(widget.newsSource)
                                      .hasCustomSupport) {
                                return ValueListenableBuilder(
                                  valueListenable: customCategory,
                                  builder: (BuildContext context, value,
                                      Widget? child) {
                                    return Flex(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      direction: Axis.horizontal,
                                      children: [
                                        Flexible(
                                          flex: 3,
                                          fit: FlexFit.tight,
                                          child: TextField(
                                            controller:
                                                customCategoryController,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: "Custom URL",
                                            ),
                                            onSubmitted: (value) {
                                              customCategory.value = value;
                                            },
                                          ),
                                        ),
                                        if (customCategory.value.isEmpty)
                                          const Flexible(
                                              child: SizedBox.shrink())
                                        else
                                          CustomCategoryTextBox(
                                            widget: widget,
                                            customCategoryPath:
                                                customCategory.value,
                                            customCategoryController:
                                                customCategoryController,
                                          )
                                      ],
                                    );
                                  },
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          );
                        }
                        return const LinearProgressIndicator();
                      }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void updateSubscription(bool? checked, UserSubscription subscription) {
    if (checked!) {
      SubscriptionPref.selectedSubscriptions = SubscriptionPref.selectedSubscriptions
        ..add(subscription);
    } else {
      SubscriptionPref.selectedSubscriptions = SubscriptionPref.selectedSubscriptions
        ..remove(subscription);
    }
  }
}

class DeleteCustomCategory extends StatelessWidget {
  final UserSubscription subscription;

  const DeleteCustomCategory({
    super.key,
    required this.subscription,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_forever),
      onPressed: () => deleteCustomSubscription(subscription),
    );
  }

  void deleteCustomSubscription(UserSubscription subscription) {
    if (SubscriptionPref.selectedSubscriptions.contains(subscription)) {
      SubscriptionPref.selectedSubscriptions = SubscriptionPref.selectedSubscriptions
        ..remove(subscription);
    }
    SubscriptionPref.customSubscriptions = SubscriptionPref.customSubscriptions..remove(subscription);
  }
}
