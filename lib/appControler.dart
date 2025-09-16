import 'package:flutter/material.dart';

class appControler extends ChangeNotifier {
  static appControler instance = appControler();
  bool darkTheme = false;
  changeTheme() {
    darkTheme = !darkTheme;
    notifyListeners();
  }
}
