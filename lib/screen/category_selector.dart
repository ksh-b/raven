import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:klaws/model/publisher.dart';
import 'package:raven/model/user_subscription.dart';
import 'package:raven/repository/preferences/subscriptions.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/widget/custom_category_textbox.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CategorySelector extends StatefulWidget {
  final Map<String, Source> publishers;
  final Source mainSource;

  const CategorySelector(this.publishers, this.mainSource, {super.key});

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.mainSource.otherVersions.length + 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text("${widget.mainSource.name} categories"),
          actions: [
            widget.mainSource.homePage.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.launch_rounded),
                    onPressed: () {
                      launchUrlString(widget.mainSource.homePage);
                    },
                  )
                : SizedBox.shrink()
          ],
          bottom: TabBar(
            tabs: [Tab(icon: Text("Main"))] +
                widget.mainSource.otherVersions
                    .map((e) => Tab(icon: Text(e.name)))
                    .toList(),
          ),
        ),
        body: TabBarView(
            children: [
                  SourceCategoryTabContent(
                    source: widget.mainSource,
                  )
                ] +
                widget.mainSource.otherVersions
                    .map((e) => SourceCategoryTabContent(
                          source: e,
                        ))
                    .toList()),
      ),
    );
  }
}

class SourceCategoryTabContent extends StatefulWidget {
  final Source source;

  SourceCategoryTabContent({
    super.key,
    required this.source,
  });

  @override
  State<SourceCategoryTabContent> createState() =>
      _SourceCategoryTabContentState();
}

class _SourceCategoryTabContentState extends State<SourceCategoryTabContent> {
  late Future<Map<String, String>> futureCategories;
  final ValueNotifier<String> customCategory = ValueNotifier<String>("");
  final TextEditingController customCategoryController =
      TextEditingController();
  final Map<String, String> categories = {};
  final List<UserFeedSubscription> availableSubscriptions = [];

  @override
  void initState() {
    super.initState();
    futureCategories = widget.source.categories(dio());
  }

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder(
      valueListenable: UserSubscriptionPref.feedSubscriptions.listenable(),
      builder: (context, value, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.source.hasSearchSupport
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
                    if (categories.connectionState ==
                        ConnectionState.done) {
                      // categories.hasData && categories.data!.isNotEmpty
                      categories.data!.forEach((key, value) {
                        availableSubscriptions.add(
                          UserFeedSubscription(widget.source, key, value),
                        );
                      });
                      List<UserFeedSubscription> allSubscriptions =
                      availableSubscriptions
                          .toSet()
                          .union(UserSubscriptionPref.customSubscriptions
                          .toSet())
                          .union(UserSubscriptionPref.selectedSubscriptions
                          .toSet())
                          .where(
                              (element) => element.source.id == widget.source.id)
                          .toList();
                      return CategoriesList(
                        allSubscriptions: allSubscriptions,
                        source: widget.source,
                        customCategory: customCategory,
                        customCategoryController: customCategoryController,
                      );
                    }
                    return CategoriesList(
                      allSubscriptions: [],
                      source: widget.source,
                      customCategory: customCategory,
                      customCategoryController: customCategoryController,
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
}

class CategoriesList extends StatelessWidget {
  const CategoriesList({
    super.key,
    required this.allSubscriptions,
    required this.source,
    required this.customCategory,
    required this.customCategoryController,
  });

  final List<UserFeedSubscription> allSubscriptions;
  final Source source;
  final ValueNotifier<String> customCategory;
  final TextEditingController customCategoryController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: allSubscriptions.length + 1,
      itemBuilder: (context, index) {
        var shouldShowCustom = source.hasCustomSupport;
        if (index == allSubscriptions.length) {
          // custom categories selector
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomCategoriesSelector(
              customCategory: customCategory,
              customCategoryController: customCategoryController,
              source: source,
              shouldShowCustom: shouldShowCustom,
            ),
          );
        }
        return CategoryCheckbox(subscription: allSubscriptions[index]);



      },
    );
  }
}

class CategoryCheckbox extends StatelessWidget {
  final UserFeedSubscription subscription;

  CategoryCheckbox({required this.subscription, super.key});

  @override
  Widget build(BuildContext context) {
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
            value: UserSubscriptionPref.selectedSubscriptions
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

  void updateSubscription(bool? checked, UserFeedSubscription subscription) {
    if (checked!) {
      UserSubscriptionPref.selectedSubscriptions =
          UserSubscriptionPref.selectedSubscriptions..add(subscription);
    } else {
      UserSubscriptionPref.selectedSubscriptions =
          UserSubscriptionPref.selectedSubscriptions..remove(subscription);
    }
  }
}

class CustomCategoriesSelector extends StatelessWidget {
  const CustomCategoriesSelector({
    super.key,
    required this.customCategory,
    required this.customCategoryController,
    required this.source,
    required this.shouldShowCustom,
  });

  final ValueNotifier<String> customCategory;
  final TextEditingController customCategoryController;
  final Source source;
  final bool shouldShowCustom;

  @override
  Widget build(BuildContext context) {
    if (!shouldShowCustom) {
      return SizedBox.shrink();
    }

    return ValueListenableBuilder(
      valueListenable: customCategory,
      builder: (BuildContext context, value, Widget? child) {
        return Flex(
          mainAxisAlignment: MainAxisAlignment.start,
          direction: Axis.horizontal,
          children: [
            Expanded(
              flex: 5,
              child: TextField(
                controller: customCategoryController,
                decoration: const InputDecoration(
                  label: Text("Custom URL"),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  customCategory.value = value;
                },
              ),
            ),
            // if (customCategory.value.isEmpty)
            //   const Flexible(child: SizedBox.shrink())
            // else
            CustomCategoryValidation(
              source: source,
              customCategoryPath: customCategory.value,
              customCategoryController: customCategoryController,
            )
          ],
        );
      },
    );
  }
}

class DeleteCustomCategory extends StatelessWidget {
  final UserFeedSubscription subscription;

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

  void deleteCustomSubscription(UserFeedSubscription subscription) {
    if (UserSubscriptionPref.selectedSubscriptions.contains(subscription)) {
      UserSubscriptionPref.selectedSubscriptions =
          UserSubscriptionPref.selectedSubscriptions..remove(subscription);
    }
    UserSubscriptionPref.customSubscriptions =
        UserSubscriptionPref.customSubscriptions..remove(subscription);
  }
}
