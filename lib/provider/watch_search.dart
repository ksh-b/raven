import 'package:flutter/material.dart';
import 'package:klaws/model/publisher.dart';
import 'package:klaws/model/watch.dart';
import 'package:raven/repository/preferences/content.dart' show ContentPref;
import 'package:raven/repository/publishers.dart';

class WatchSourceSearchProvider extends ChangeNotifier {
  Map<String, Watch> watches = {
    for (var watch in ContentPref.watchSources)
      watch.id: watch
  };

  // final List<Watch> _publishers = publishers.values.toList();
  // List<Watch> filteredPublishers = publishers.values.toList();

  bool _isInProgress = false;

  bool get isInProgress => _isInProgress;

  set isInProgress(bool value) {
    _isInProgress = value;
    notifyListeners();
  }

  // void searchPublishersByCategory(String category) {
  //   if (category == "All") {
  //     filteredPublishers = _publishers;
  //     notifyListeners();
  //     return;
  //   }
  //
  //   filteredPublishers = _publishers.where((publisher) {
  //     return publisher.watch.category.contains(category);
  //   }).toList();
  //   notifyListeners();
  // }

  // void searchPublishersByName(String query) {
  //   filteredPublishers = _publishers.where((publisher) {
  //     return publisher.id.toLowerCase().contains(query);
  //   }).toList();
  //
  //   notifyListeners();
  // }
}
