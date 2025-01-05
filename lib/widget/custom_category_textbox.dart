import 'package:flutter/material.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/model/user_subscription.dart';
import 'package:raven/repository/preferences/subscriptions.dart';
import 'package:raven/repository/publishers.dart';
import 'package:raven/utils/string.dart';

class CustomCategoryTextBox extends StatelessWidget {
  const CustomCategoryTextBox({
    super.key,
    required this.source,
    required this.customCategoryPath,
    required this.customCategoryController,
  });

  final Source source;
  final String customCategoryPath;
  final TextEditingController customCategoryController;

  @override
  Widget build(BuildContext context) {
    var userDefinedCategory = publishers[source.id]
        ?.articles(category: customCategoryPath);
    return Flexible(
      flex: 1,
      child: FutureBuilder(
        future: userDefinedCategory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError ||
              (snapshot.hasData && snapshot.data!.isEmpty)) {
            return const Icon(Icons.cancel);
          }
          if (customCategoryController.text.isEmpty) {
            return const SizedBox.shrink();
          }
          if (snapshot.hasData) {
            return IconButton(
              onPressed: () => saveCustomSubscription(),
              icon: const Icon(Icons.save_alt),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void saveCustomSubscription() {
    customCategoryController.text = "";
    UserSubscriptionPref.customSubscriptions += [
      UserFeedSubscription(
        source,
        baseName(customCategoryPath),
        customCategoryPath,
        isCustom: true,
      )
    ];
  }
}
