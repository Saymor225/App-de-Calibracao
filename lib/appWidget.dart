import 'package:appcalibracao/HomePage.dart';
import 'package:appcalibracao/appControler.dart';
import 'package:flutter/material.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: appControler.instance,
        builder: (context, child) {
          return MaterialApp(
            theme: ThemeData(
              primaryColor: Colors.red,
              brightness: appControler.instance.darkTheme
                  ? Brightness.dark
                  : Brightness.light,
            ),
            home: HomePage(),
          );
        });
  }
}
