import 'package:hive_ce/hive.dart';
import 'package:klaws/model/source/watch_dart.dart';
import 'package:raven/model/user_subscription.dart';
import 'package:klaws/model/watch.dart';
import 'package:raven/model/watch_item_history.dart';

class UserSubscriptionPref {
  static Box get feedSubscriptions {
    return Hive.box("subscriptions");
  }

  static List<UserFeedSubscription> get selectedSubscriptions {
    return List<UserFeedSubscription>.from(
      feedSubscriptions.get(
        "selected",
        defaultValue: [],
      ) as Iterable,
    );
  }

  static set selectedSubscriptions(
      List<UserFeedSubscription> newSubscriptions) {
    feedSubscriptions.put("selected", newSubscriptions);
  }

  static List<UserFeedSubscription> get customSubscriptions {
    return List<UserFeedSubscription>.from(
      feedSubscriptions.get(
        "custom",
        defaultValue: [],
      ) as Iterable,
    );
  }

  static set customSubscriptions(List<UserFeedSubscription> newSubscriptions) {
    feedSubscriptions.put("custom", newSubscriptions);
  }

  static Box<WatchItemHistory> get watchSubscriptions {
    return Hive.box("watch-subscriptions");
  }

  static List<WatchItemHistory> getAllWatchSubs() {
    return watchSubscriptions.values.toList();
  }

  static WatchItemHistory? getWatchItem(String id) {
    return watchSubscriptions.get(id);
  }

  static upsertWatchItem(Watch watch, Items items) {
    WatchItemHistory? watchItem = getWatchItem("${watch.id}:${items.url}");
    if (watchItem==null) {
      return watchSubscriptions.put(
        "${watch.id}:${items.url}",
        WatchItemHistory(
          watch: watch,
          itemsHistory: watchItem==null?[items]:watchItem.itemsHistory..add(items),
          lastUpdate: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } else {
      watchItem.lastUpdate = DateTime.now().millisecondsSinceEpoch;
      watchItem.itemsHistory.add(items);
      watchSubscriptions.delete("${watch.id}:${items.url}");
      watchSubscriptions.put("${watch.id}:${items.url}", watchItem);
    }
  }
}
