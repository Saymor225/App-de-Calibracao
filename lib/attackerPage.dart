import 'package:flutter/material.dart';

class AttackerPage extends StatefulWidget {
  const AttackerPage({super.key});

  @override
  State<AttackerPage> createState() => _AttackerPageState();
}

class _AttackerPageState extends State<AttackerPage> {
  final List<Map<String, dynamic>> estados = [
    {"nome": "Attacking", "kp": 0.0, "kd": 0.0, "pwm": 0.0},
    {"nome": "Seeking", "kp": 0.0, "kd": 0.0, "pwm": 0.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attacker - Calibration"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: estados.length,
        itemBuilder: (context, index) {
          final estado = estados[index];
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
                  estados.add({"nome": nome, "kp": 0.0, "kd": 0.0, "pwm": 0.0});
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
          "Are you sure you want to remove the state '${estados[index]["nome"]}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                estados.removeAt(index);
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
