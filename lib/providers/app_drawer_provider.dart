import 'package:flutter/material.dart';

class DrawerProvider with ChangeNotifier {
  GlobalKey<ScaffoldState>? _scaffoldKey;

  set scaffoldKey(GlobalKey<ScaffoldState> key) {
    _scaffoldKey = key;
  }

  void openDrawer() {
    _scaffoldKey?.currentState?.openDrawer();
  }
}
