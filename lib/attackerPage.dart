import 'package:flutter/material.dart';
import 'dart:convert';
import 'JsonSendWidget.dart';
// Necessário para RawDatagramSocket e InternetAddress

// ------------------------------------------------------------------
// A LISTA DE ESTADOS É GLOBAL E PERSISTENTE
// ------------------------------------------------------------------
final List<Map<String, dynamic>> attackerEstados = [
  {"nome": "Attacking", "kp": 0.0, "kd": 0.0, "pwm": 0.0},
  {"nome": "Seeking", "kp": 0.0, "kd": 0.0, "pwm": 0.0},
];
// ------------------------------------------------------------------

class AttackerPage extends StatefulWidget {
  const AttackerPage({super.key});

  @override
  State<AttackerPage> createState() => _AttackerPageState();
}

class _AttackerPageState extends State<AttackerPage> {
  // ------------------------------------------------------------------
  // CONFIGURAÇÃO DO SERVIDOR UDP (Mude para o IP da sua máquina Windows)
  // ------------------------------------------------------------------
  static const String serverIp =
      '192.168.1.102'; // Mude para o IP da sua máquina Windows/servidor
  static const int serverPort = 8888; // Porta configurada no servidor C++
  // ------------------------------------------------------------------

  // Função para gerar o mapa no formato JSON
  Map<String, dynamic> _generateJson() {
    final Map<String, dynamic> attackerData = {};

    for (final estado in attackerEstados) {
      final key = estado["nome"].toString();

      attackerData[key] = {
        "kp": estado["kp"],
        "kd": estado["kd"],
        "pwm": estado["pwm"],
      };
    }

    return {"Attacker": attackerData};
  }

  // A FUNÇÃO UDP AGORA FAZ PARTE DA CLASSE STATE

  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attacker - Calibration"),
        centerTitle: true,
        actions: [
          UdpSendButton(
            jsonGenerator:
                _generateJson, // Passa a referência da função geradora
            serverIp: serverIp,
            serverPort: serverPort,
            debugLabel: 'Calibração ATACANTE',
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
        itemCount: attackerEstados.length,
        itemBuilder: (context, index) {
          final estado = attackerEstados[index];
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
                  attackerEstados
                      .add({"nome": nome, "kp": 0.0, "kd": 0.0, "pwm": 0.0});
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
          "Are you sure you want to remove the state '${attackerEstados[index]["nome"]}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                attackerEstados.removeAt(index);
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
