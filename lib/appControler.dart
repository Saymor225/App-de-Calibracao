import 'package:flutter/material.dart';

class appControler extends ChangeNotifier {
  static appControler instance = appControler();
  bool darkTheme = true;
  changeTheme() {
    darkTheme = !darkTheme;
    notifyListeners();
  }
}
