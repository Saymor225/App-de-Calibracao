import 'package:flutter/material.dart';
import 'server_config.dart';
import 'package:provider/provider.dart';
import 'appWidget.dart';

main() {
  runApp(ChangeNotifierProvider(
    create: (context) => ServerConfig(),
    child: AppWidget(), // Seu widget principal
  ));
}
