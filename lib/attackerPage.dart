import 'package:flutter/material.dart';
import 'dart:convert';

// ------------------------------------------------------------------
// A LISTA DE ESTADOS É AGORA GLOBAL E PERSISTENTE
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
  // A lista 'estados' original foi removida daqui

  // Função para gerar o mapa no formato desejado
  Map<String, dynamic> _generateJson() {
    final Map<String, dynamic> attackerData = {};

    // Usa a lista global
    for (final estado in attackerEstados) {
      final key = estado["nome"].toString();

      attackerData[key] = {
        "kp": estado["kp"],
        "kd": estado["kd"],
        "pwm": estado["pwm"],
      };
    }

    return {"atacante": attackerData};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attacker - Calibration"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () {
              final jsonData = _generateJson();
              final jsonString = jsonEncode(jsonData);

              print("--- JSON Gerado ---");
              print(jsonString);
              print("-------------------");

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('JSON gerado e impresso no console!')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: attackerEstados.length, // Usa a lista global
        itemBuilder: (context, index) {
          final estado = attackerEstados[index]; // Usa a lista global
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
              // Todas as chamadas de _buildCalibration também usam a lista global
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
    // ... (Método _buildCalibration inalterado)
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
                  // Adiciona à lista global
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
          "Are you sure you want to remove the state '${attackerEstados[index]["nome"]}'?", // Usa a lista global
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                attackerEstados.removeAt(index); // Remove da lista global
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
