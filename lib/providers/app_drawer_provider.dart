import 'package:flutter/material.dart';

class AppDrawerProvider with ChangeNotifier {
  bool _isOpen = false;

  bool get isOpen => _isOpen;

  void toggleDrawer() {
    _isOpen = !_isOpen;
    notifyListeners();
  }
}
