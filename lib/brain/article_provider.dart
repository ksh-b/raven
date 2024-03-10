// ignore_for_file: unused_import

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:whapp/model/article.dart';
import 'package:whapp/model/publisher.dart';
import 'package:whapp/utils/store.dart';

class ArticleProvider {
  int few = 5;
  Set<NewsArticle> stashedArticles = {};
  HashMap<String, int> nextPage = HashMap();

  Future<List<NewsArticle>> loadPage(int page, {String? query}) async {
    List<NewsArticle> newsArticles = [];
    List<NewsArticle> subscriptionArticles = [];
    List subscriptions = Store.selectedSubscriptions;

    // Load user subscriptions (Publisher+Category)
    for (var subscription in subscriptions) {
      // get publisher for this subscription
      Publisher publisher = publishers[subscription.publisher]!;

      // if there are any articles in stash
      var stashedPublisherArticles = stashedArticles.where((e) => e.publisher==publisher).toList();
      if (stashedPublisherArticles.isNotEmpty) {
        subscriptionArticles = stashedPublisherArticles.take(few).toList();
        stashedArticles.removeAll(subscriptionArticles);
      }

      // else get fresh articles for this subscription
      else {
        int page_ = nextPage.containsKey(subscription.toString()) ? nextPage[subscription.toString()]! : page;

        if (query!=null) {
          await publisher
              .searchedArticles(page: page_, searchQuery: query)
              .then((articles) {
            collectPublisherArticles(subscriptionArticles, articles, subscription, page);
          });
        } else {
          await publisher
            .categoryArticles(page: page_, category: subscription.category)
            .then((articles) {
          collectPublisherArticles(subscriptionArticles, articles, subscription, page);
        });
        }
      }
    }

    newsArticles.addAll(subscriptionArticles);
    return newsArticles;
  }

  void collectPublisherArticles(List<NewsArticle> subscriptionArticles, Set<NewsArticle> articles, subscription, int page) {
    subscriptionArticles.addAll(articles.take(few).toList());
    var stashedArticles_ = articles.skip(few);
    stashedArticles.addAll(stashedArticles_);
    if(stashedArticles_.isNotEmpty) {
      nextPage[subscription.toString()] = nextPage.containsKey(subscription.toString()) ?
      (nextPage[subscription.toString()]!+1):page+1;
    }
    
    // sort - show most recent first
    subscriptionArticles.sort((a, b) =>
        a.publishedAt.key.compareTo(b.publishedAt.key));
  }

}
