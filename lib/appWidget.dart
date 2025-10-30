import 'package:appcalibracao/HomePage.dart';
import 'package:appcalibracao/appControler.dart';
import 'package:flutter/material.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: appControler.instance,
        builder: (context, child) {
          const Color primarySeedColor = Color.fromARGB(255, 5, 62, 247);
          final Brightness themeBrightness = appControler.instance.darkTheme
              ? Brightness.dark
              : Brightness.light;

          return MaterialApp(
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
              seedColor: primarySeedColor,
              brightness: themeBrightness,
            )),
            home: HomePage(),
          );
        });
  }
}
