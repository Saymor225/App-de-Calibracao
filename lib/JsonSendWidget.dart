import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

typedef JsonGenerator = Map<String, dynamic> Function();

// Definição do Widget UdpSendButton
class UdpSendButton extends StatelessWidget {
  final JsonGenerator jsonGenerator;
  final String serverIp;
  final int serverPort;
  final String debugLabel;

  const UdpSendButton({
    super.key,
    required this.jsonGenerator,
    required this.serverIp,
    required this.serverPort,
    required this.debugLabel,
  });

  // A LÓGICA DE ENVIO UDP É MOVIDA PARA DENTRO DESTE WIDGET
  Future<void> _sendJsonViaUdp(BuildContext context) async {
    final jsonData = jsonGenerator();
    final jsonString = jsonEncode(jsonData);

    final targetIp = InternetAddress(serverIp);

    // --- Feedback Inicial ---
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Tentando enviar $debugLabel para $serverIp:$serverPort...')),
    );
    print('[$debugLabel] Enviando JSON via UDP para: $serverIp:$serverPort');

    RawDatagramSocket? socket;

    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      List<int> data = utf8.encode(jsonString);

      int sent = socket.send(data, targetIp, serverPort);

      // --- Feedback Final ---
      if (sent == data.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ $debugLabel enviado: $sent bytes!')),
        );
        print('[$debugLabel] JSON enviado com sucesso: $sent bytes');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Falha ao enviar datagrama completo.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Erro de rede $debugLabel: ${e.toString()}')),
      );
      print('[$debugLabel] ⚠️ Erro de socket UDP: $e');
    } finally {
      socket?.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.send),
      tooltip: debugLabel,
      onPressed: () =>
          _sendJsonViaUdp(context), // Passa o contexto para o SnackBar
    );
  }
}
