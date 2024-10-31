import 'package:hive/hive.dart';
import 'package:raven/model/user_subscription.dart';

class SubscriptionPref {
  static Box get subscriptions {
    return Hive.box("subscriptions");
  }

  static List<UserSubscription> get selectedSubscriptions {
    return List<UserSubscription>.from(
      subscriptions.get(
        "selected",
        defaultValue: [],
      ),
    );
  }

  static set selectedSubscriptions(List<UserSubscription> newSubscriptions) {
    subscriptions.put("selected", newSubscriptions);
  }

  static List<UserSubscription> get customSubscriptions {
    return List<UserSubscription>.from(
      subscriptions.get(
        "custom",
        defaultValue: [],
      ),
    );
  }

  static set customSubscriptions(List<UserSubscription> newSubscriptions) {
    subscriptions.put("custom", newSubscriptions);
  }
}
