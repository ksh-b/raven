import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:raven/provider/article.dart';
import 'package:raven/provider/search.dart';
import 'package:raven/repository/preferences/subscriptions.dart';
import 'package:raven/widget/article_card.dart';
import 'package:raven/widget/blank_page_message.dart';
import 'package:raven/widget/tags.dart';

class FeedPageDelegate extends StatefulWidget {
  final String query;

  const FeedPageDelegate({super.key, required this.query});

  @override
  State<FeedPageDelegate> createState() => _FeedPageDelegateState();
}

class _FeedPageDelegateState extends State<FeedPageDelegate> {
  @override
  void initState() {
    super.initState();
    if (widget.query.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ArticleSearchProvider>().refresh(widget.query);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ArticleProvider>().refresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.query.isNotEmpty) {
      return SearchArticleProviderConsumer(widget: widget);
    } else {
      return ArticleProviderConsumer(widget: widget);
    }
  }
}

class ArticleProviderConsumer extends StatelessWidget {
  const ArticleProviderConsumer({
    super.key,
    required this.widget,
  });

  final FeedPageDelegate widget;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: SubscriptionPref.subscriptions.listenable(),
      builder: (context, value, child) {
        return Consumer<ArticleProvider>(
          builder: (context, articleProvider, child) {
            List<Widget> tiles = articleProvider.filteredArticles
                .map((article) => ArticleCard(article))
                .toList();

            if (tiles.isEmpty && SubscriptionPref.selectedSubscriptions.isEmpty) {
              return const BlankPageMessage(
                  "Please select some subscriptions to get started",
              );
            }

            return RefreshIndicator(
              onRefresh: () {
                return articleProvider.refresh();
              },
              child: ListView.builder(
                itemCount: tiles.length + 2,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    if (articleProvider.isLoading) {
                      return const LinearProgressIndicator();
                    } return const Tags();
                  } else if (tiles.isNotEmpty && index - 1 < tiles.length) {
                    return tiles[index - 1];
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: articleProvider.isLoading
                            ? null
                            : () => articleProvider.nextPage(),
                        child: Text(
                          articleProvider.isLoading ? "Loading" : "Load More",
                        ),
                      ),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}

class SearchArticleProviderConsumer extends StatelessWidget {
  const SearchArticleProviderConsumer({
    super.key,
    required this.widget,
  });

  final FeedPageDelegate widget;

  @override
  Widget build(BuildContext context) {
    return Consumer<ArticleSearchProvider>(
      builder: (context, articleProvider, child) {
        List<Widget> tiles = articleProvider.filteredArticles
            .map((article) => ArticleCard(article))
            .toList();
        return RefreshIndicator(
          onRefresh: () {
            return articleProvider.refresh(widget.query);
          },
          child: ListView.builder(
            itemCount: tiles.length + 2,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                if (articleProvider.isLoading) {
                  return const LinearProgressIndicator();
                } return const Tags();
              } else if (tiles.isNotEmpty && index - 1 < tiles.length) {
                return tiles[index - 1];
              } else {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: articleProvider.isLoading
                        ? null
                        : () => articleProvider.nextPage(),
                    child: Text(
                      articleProvider.isLoading ? "Loading" : "Load More",
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
