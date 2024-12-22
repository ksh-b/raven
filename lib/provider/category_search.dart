import 'package:flutter/material.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/repository/publishers.dart';

class CategorySearchProvider extends ChangeNotifier {
  final List<Source> _publishers = publishers.values.toList();
  List<Source> filteredPublishers = publishers.values.toList();

  bool _isInProgress = false;

  bool get isInProgress => _isInProgress;

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
      return publisher.id.toLowerCase().contains(query);
    }).toList();

    notifyListeners();
  }
}
