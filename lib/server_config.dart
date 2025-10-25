// server_config.dart
import 'package:flutter/material.dart';

// Constantes Padrão
const String _DEFAULT_IP = '192.168.1.103';
const int _DEFAULT_PORT = 8888;

class ServerConfig extends ChangeNotifier {
  // Padrão Singleton
  static final ServerConfig _instance = ServerConfig._internal();
  factory ServerConfig() => _instance;
  ServerConfig._internal();

  String ip = _DEFAULT_IP;
  int port = _DEFAULT_PORT;

  // MÉTODOS SIMPLES DE ALTERAÇÃO (NÃO PERSISTEM)

  void setIp(String newIp) {
    if (ip == newIp) return;
    ip = newIp;
    notifyListeners(); // Notifica widgets para reconstruir
  }

  void setPort(int newPort) {
    if (port == newPort) return;
    port = newPort;
    notifyListeners(); // Notifica widgets para reconstruir
  }
}
