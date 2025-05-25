import 'package:flutter/material.dart';
import 'package:klaws/model/publisher.dart';
import 'package:raven/model/user_subscription.dart';
import 'package:raven/repository/preferences/subscriptions.dart';
import 'package:raven/repository/publishers.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/string.dart';

class CustomCategoryValidation extends StatelessWidget {
  const CustomCategoryValidation({
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
    var userDefinedCategory = customCategoryController.text.isNotEmpty?publishers()[source.id]
        ?.articles(category: customCategoryController.text, dio: dio()):null;
    return Expanded(
      flex: 1,
      child: FutureBuilder(
        future: userDefinedCategory,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            saveCustomSubscription();
          }
          if (customCategoryController.text.isEmpty || customCategoryPath.isEmpty) {
            return const SizedBox.shrink();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Icon(Icons.access_time_rounded);
          }
          if (snapshot.data==null || snapshot.hasError || (snapshot.hasData && snapshot.data!.isEmpty)) {
            return const Icon(Icons.cancel);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void saveCustomSubscription() {
    UserSubscriptionPref.customSubscriptions += [
      UserFeedSubscription(
        source,
        baseName(customCategoryController.text),
        customCategoryController.text,
        isCustom: true,
      )
    ];
    customCategoryController.text = "";
  }
}
