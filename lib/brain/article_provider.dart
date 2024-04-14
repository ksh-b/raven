import 'dart:collection';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/model/user_subscription.dart';
import 'package:raven/utils/store.dart';

class ArticleProvider {
  int few = 5;
  Set<NewsArticle> stashedArticles = {};
  HashMap<String, int> nextPage = HashMap();

  void reset() {
    stashedArticles = {};
    nextPage = HashMap();
  }

  Future<List<NewsArticle>> loadPage(int page, {String? query}) async {
    List<Future> futures = [];
    List<NewsArticle> newsArticles = [];
    List<NewsArticle> subscriptionArticles = [];
    List<UserSubscription> subscriptions = Store.selectedSubscriptions;
    bool needFresh = false;

    // Load user subscriptions (Publisher+Category)
    for (var subscription in subscriptions) {
      // get publisher for this subscription
      Publisher publisher = publishers[subscription.publisher]!;
      // if there are any articles in stash, un-stash them
      var stashedPublisherArticles = stashedArticles
          .where((e) => e.publisher.toString() == publisher.toString())
          .toList();
      if (stashedPublisherArticles.isNotEmpty) {
        subscriptionArticles = stashedPublisherArticles.take(few).toList();
        stashedArticles.removeAll(subscriptionArticles);
      }

      // else get fresh articles for this subscription
      else {
        needFresh = true;
        int page_ = nextPage.containsKey(subscription.toString())
            ? nextPage[subscription.toString()]!
            : page;

        if (query != null) {
          futures.add(publisher.searchedArticles(
              searchQuery: query,
              page: page_,
            ).then(
              (value) {
                collectPublisherArticles(
                  subscriptionArticles,
                  value,
                  "${value.first.publisher.name}~${value.first.category}",
                  page,
                );
              },
            ),
          );
        } else {
          futures.add(publisher.categoryArticles(
            category: subscription.category,
            page: page_,
          ).then(
            (value) {
              collectPublisherArticles(
                subscriptionArticles,
                value,
                "${value.first.publisher.name}~${value.first.category}",
                page,
              );
            },
          ),);
        }
      }
    }
    if (needFresh)
      await Future.wait(futures);
    newsArticles.addAll(subscriptionArticles);
    return newsArticles;
  }

  void collectPublisherArticles(
    List<NewsArticle> subscriptionArticles,
    Set<NewsArticle> articles,
    String subscription,
    int page,
  ) {
    subscriptionArticles.addAll(articles.take(few).toList());
    var stashedArticles_ = articles.skip(few);
    stashedArticles.addAll(stashedArticles_);
    if (stashedArticles_.isNotEmpty) {
      nextPage[subscription] = nextPage.containsKey(subscription)
          ? (nextPage[subscription]! + 1)
          : page + 1;
    }

    // sort - show most recent first
    subscriptionArticles
        .sort((a, b) => a.publishedAt.key.compareTo(b.publishedAt.key));
  }
}
