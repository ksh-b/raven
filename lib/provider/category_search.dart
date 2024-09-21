import 'package:flutter/material.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/repository/publishers.dart';

class CategorySearchProvider extends ChangeNotifier {
  final List<String> _publishers = publishers.keys.toList();
  List<String> filteredPublishers = publishers.keys.toList();

  bool _isInProgress = false;

  bool get isInProgress => _isInProgress;

  set isInProgress(bool value) {
    _isInProgress = value;
    notifyListeners();
  }

  void searchPublishersByCategory(String category) {
    if (category == "all") {
      filteredPublishers = _publishers;
      notifyListeners();
      return;
    }

    filteredPublishers = _publishers.where((publisher) {
      return Publisher.fromString(publisher).mainCategory == category;
    }).toList();
    notifyListeners();
  }

  void searchPublishersByName(String query) {
    filteredPublishers = _publishers.where((publisher) {
      return publisher.toLowerCase().contains(query);
    }).toList();

    notifyListeners();
  }
}
