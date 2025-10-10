import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io'; // Necessário para RawDatagramSocket e InternetAddress

// ------------------------------------------------------------------
// A LISTA DE ESTADOS É GLOBAL E PERSISTENTE
// ------------------------------------------------------------------
final List<Map<String, dynamic>> DefenderEstados = [
  {"nome": "Attacking", "kp": 0.0, "kd": 0.0, "pwm": 0.0},
  {"nome": "Seeking", "kp": 0.0, "kd": 0.0, "pwm": 0.0},
];
// ------------------------------------------------------------------

class DefenderPage extends StatefulWidget {
  const DefenderPage({super.key});

  @override
  State<DefenderPage> createState() => _DefenderPageState();
}

class _DefenderPageState extends State<DefenderPage> {
  // ------------------------------------------------------------------
  // CONFIGURAÇÃO DO SERVIDOR UDP (Mude para o IP da sua máquina Windows)
  // ------------------------------------------------------------------
  static const String serverIp =
      '192.168.1.102'; // Mude para o IP da sua máquina Windows/servidor
  static const int serverPort = 8888; // Porta configurada no servidor C++
  // ------------------------------------------------------------------

  // Função para gerar o mapa no formato JSON
  Map<String, dynamic> _generateJson() {
    final Map<String, dynamic> DefenderData = {};

    for (final estado in DefenderEstados) {
      final key = estado["nome"].toString();

      DefenderData[key] = {
        "kp": estado["kp"],
        "kd": estado["kd"],
        "pwm": estado["pwm"],
      };
    }

    return {"Defender": DefenderData};
  }

  // A FUNÇÃO UDP AGORA FAZ PARTE DA CLASSE STATE
  Future<void> _sendJsonViaUdp() async {
    final jsonData = _generateJson();
    final jsonString = jsonEncode(jsonData);

    // Converte o IP de string para InternetAddress
    final targetIp = InternetAddress(serverIp);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Tentando enviar UDP para $serverIp:$serverPort...')),
    );
    print('Enviando JSON via UDP para: $serverIp:$serverPort');

    RawDatagramSocket? socket;

    try {
      // 1. Cria um socket UDP que se liga a qualquer interface e porta livre (0)
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

      // 2. Converte a string JSON para bytes (codificação UTF-8)
      List<int> data = utf8.encode(jsonString);

      // 3. Envia o datagrama
      int sent = socket.send(data, targetIp, serverPort);

      // O UDP não tem confirmação garantida, mas podemos confirmar que o SO o enviou.
      if (sent == data.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Datagrama UDP enviado: $sent bytes!')),
        );
        print('✅ JSON enviado via UDP com sucesso: $sent bytes');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Falha ao enviar datagrama completo.')),
        );
        print(
            '❌ Falha ao enviar datagrama completo: $sent de ${data.length} bytes.');
      }
    } catch (e) {
      // Erro de rede (ex: IPAddress inválido ou falha de binding)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Erro de socket UDP: ${e.toString()}')),
      );
      print('⚠️ Erro de socket UDP: $e');
    } finally {
      // Garante que o socket seja fechado
      socket?.close();
    }
  }

  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Defender - Calibration"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.send), // Ícone de envio
            onPressed: _sendJsonViaUdp, // CHAMA A NOVA FUNÇÃO UDP AQUI
          ),
          IconButton(
            icon: const Icon(
                Icons.code), // Mantém o botão de debug para ver o JSON
            onPressed: () {
              final jsonString = jsonEncode(_generateJson());
              print("--- JSON Gerado ---");
              print(jsonString);
              print("-------------------");

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('JSON copiado para o console.')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: DefenderEstados.length,
        itemBuilder: (context, index) {
          final estado = DefenderEstados[index];
          return ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(estado["nome"]),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmarDelete(index),
                ),
              ],
            ),
            children: [
              _buildCalibration(
                "Kp",
                estado["kp"],
                (value) => setState(() => estado["kp"] = value),
              ),
              _buildCalibration(
                "Kd",
                estado["kd"],
                (value) => setState(() => estado["kd"] = value),
              ),
              _buildCalibration("pwm", estado["pwm"],
                  (value) => setState(() => estado["pwm"] = value)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarEstado,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalibration(
      String label, double currentValue, Function(double) onChanged) {
    final controller =
        TextEditingController(text: currentValue.toStringAsFixed(2));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text("$label: "),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (val) {
                final parsed = double.tryParse(val);
                if (parsed != null) {
                  onChanged(parsed);
                }
                controller.text = parsed?.toStringAsFixed(2) ?? "0.00";
              },
            ),
          ),
        ],
      ),
    );
  }

  void _adicionarEstado() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New State"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Enter state name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final nome = controller.text.trim();
              if (nome.isNotEmpty) {
                setState(() {
                  DefenderEstados.add(
                      {"nome": nome, "kp": 0.0, "kd": 0.0, "pwm": 0.0});
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _confirmarDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove State"),
        content: Text(
          "Are you sure you want to remove the state '${DefenderEstados[index]["nome"]}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                DefenderEstados.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }
}
