import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _navIndex = 0;

  int get index => _navIndex;

  set index(int value) {
    _navIndex = value;
    notifyListeners();
  }
}
