import 'package:flutter/material.dart';
import 'package:klaws/model/publisher.dart';
import 'package:raven/repository/publishers.dart';

class FeedSourceSearchProvider extends ChangeNotifier {

  bool _isInProgress = false;
  List<Source> _publishers = [];
  List<Source> filteredPublishers= [];
  bool get isInProgress => _isInProgress;

  FeedSourceSearchProvider () {
    update();
  }

  set isInProgress(bool value) {
    _isInProgress = value;
    notifyListeners();
  }

  void searchPublishersByCategory(String category) {
    if (category == "All") {
      filteredPublishers = _publishers;
      notifyListeners();
      return;
    }

    filteredPublishers = _publishers.where((publisher) {
      return publisher.siteCategories.contains(category);
    }).toList();
    notifyListeners();
  }

  void searchPublishersByName(String query) {
    filteredPublishers = _publishers.where((publisher) {
      return publisher.name.toLowerCase().contains(query);
    }).toList();

    notifyListeners();
  }


  void update() {
    _publishers = publishers().values.toList();
    filteredPublishers = publishers().values.toList();
    notifyListeners();
  }
}
