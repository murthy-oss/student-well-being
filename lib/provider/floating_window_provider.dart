import 'package:flutter/material.dart';

class FloatingWindowProvider extends ChangeNotifier {
  bool _isFloatingDrawerOpen = false;

  bool get isFloatingDrawerOpen => _isFloatingDrawerOpen;

  void toggleFloatingDrawer() {
    _isFloatingDrawerOpen = !_isFloatingDrawerOpen;
    notifyListeners();
  }
}
