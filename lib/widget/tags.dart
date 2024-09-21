import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raven/provider/article.dart';

class Tags extends StatelessWidget {
  const Tags({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Consumer<ArticleProvider>(
          builder: (
            BuildContext context,
            ArticleProvider articleProvider,
            Widget? child,
          ) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: articleProvider.tags.keys.map(
                (key) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4),
                    child: ChoiceChip(
                      label: Text(key),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      selected: articleProvider.selectedTags.contains(key),
                      onSelected: (selected) {
                        articleProvider.updateTags(selected, key);
                      },
                    ),
                  );
                },
              ).toList(),
            );
          },
        ),
      ),
    );
  }
}
