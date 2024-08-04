import 'package:flutter/material.dart';

class DrawerProvider with ChangeNotifier {
  GlobalKey<ScaffoldState>? _scaffoldKey;
  bool _isLoading = false;
  String _userName = '';

  set scaffoldKey(GlobalKey<ScaffoldState> key) {
    _scaffoldKey = key;
  }

  void openDrawer() {
    _scaffoldKey?.currentState?.openDrawer();
  }

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String get userName => _userName;

  set userName(String name) {
    _userName = name;
    notifyListeners();
  }
}
