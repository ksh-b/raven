import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:raven/model/filter.dart';
import 'package:raven/repository/preferences/content.dart';
import 'package:raven/repository/publishers.dart';
import 'package:raven/widget/new_filter_popup.dart';

class CustomizeFilters extends StatefulWidget {
  const CustomizeFilters({super.key});

  @override
  State<CustomizeFilters> createState() => _CustomizeFiltersState();
}

class _CustomizeFiltersState extends State<CustomizeFilters> {
  @override
  Widget build(BuildContext context) {
    var filters = ContentPref.filters.map((e) {
      return ListTile(
        leading: SizedBox(
          width: 32,
          height: 32,
          child: e.publisher == "any"
              ? Icon(Icons.all_inclusive_rounded)
              : CachedNetworkImage(imageUrl: publishers[e.publisher]!.iconUrl),
        ),
        title: Text(e.keyword),
        subtitle: Text(e.publisher),
        trailing: IconButton(
            onPressed: () {
              ContentPref.filters = ContentPref.filters..remove(e);
            },
            icon: Icon(Icons.delete_rounded)),
      );
    }).toList();

    if (filters.isEmpty) {
      filters = [
        ListTile(
          title: Text("No filters added"),
        )
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Customize Filters"),
      ),
      body: ListView(children: filters),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_rounded),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return NewFilterPopup();
            },
          );
        },
      ),
    );
  }

  String filterCriteria(Filter e) {
    if (e.inTags) {
      return "Tags";
    } else if (e.inUrl) {
      return "URL";
    } else if (e.inTitle) {
      return "Title";
    } else if (e.inAuthor) {
      return "Author";
    } else if (e.inContent) {
      return "Content";
    } else {
      return "Anywhere";
    }
  }
}
