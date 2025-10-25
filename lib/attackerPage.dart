import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart'; // Import necessário
import 'JsonSendWidget.dart';
import 'server_config.dart'; // Importa a classe simples de IP/Porta

// ------------------------------------------------------------------
// LISTA DE ESTADOS DE CALIBRAÇÃO (Mantendo a persistência de arquivo JSON)
// ------------------------------------------------------------------
List<Map<String, dynamic>> attackerEstados = [];

const List<Map<String, dynamic>> _ATTACKER_DEFAULT_ESTADOS = [
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
  // OMITIDO: static const serverIp e serverPort

  @override
  void initState() {
    super.initState();
    // Você ainda precisa carregar o estado de CALIBRAÇÃO do arquivo JSON
    // Se não tiver essa parte, comente ou ignore.
    _loadEstados();
  }

  // #################### Funções de Persistência (CALIBRAÇÃO) ####################
  // Estas funções permanecem as mesmas para persistir os Kp/Kd/pwm

  Future<File> get _localFile async {
    final directory = Directory.systemTemp;
    return File('${directory.path}/attacker_config.json');
  }

  Future<void> _saveEstados() async {
    try {
      final file = await _localFile;
      final jsonString = jsonEncode(attackerEstados);
      await file.writeAsString(jsonString);
    } catch (_) {}
  }

  Future<void> _loadEstados() async {
    List<Map<String, dynamic>> estadosCarregados = [];
    bool success = false;

    try {
      final file = await _localFile;
      if (await file.exists()) {
        final String jsonString = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(jsonString);
        estadosCarregados =
            jsonList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        success = estadosCarregados.isNotEmpty;
      }
    } catch (_) {}

    if (!success) {
      estadosCarregados = _ATTACKER_DEFAULT_ESTADOS
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    setState(() {
      attackerEstados = estadosCarregados;
    });

    if (!success) {
      await _saveEstados();
    }
  }

  void _updateAndSave(VoidCallback updateCallback) {
    setState(() {
      updateCallback();
    });
    _saveEstados();
  }
  // #################### Fim Persistência CALIBRAÇÃO ####################

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

  // NOVO: Método para mostrar o diálogo de configuração
  void _showConfigDialog(BuildContext context) {
    // Acessa o objeto de configuração (não o Consumer)
    final config = Provider.of<ServerConfig>(context, listen: false);
    final ipController = TextEditingController(text: config.ip);
    final portController = TextEditingController(text: config.port.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Configuração de Rede"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ipController,
              decoration: const InputDecoration(
                  labelText: "Endereço IP (Não persistente)"),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: portController,
              decoration: const InputDecoration(
                  labelText: "Porta UDP (Não persistente)"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              final newIp = ipController.text.trim();
              final newPort = int.tryParse(portController.text.trim());

              config.setIp(newIp);

              config.setPort(newPort!);

              Navigator.pop(context);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attacker - Calibration"),
        centerTitle: true,
        actions: [
          // USANDO CONSUMER para reconstruir APENAS o botão UDP quando o IP/Porta mudar
          Consumer<ServerConfig>(
            builder: (context, config, child) {
              return UdpSendButton(
                jsonGenerator: _generateJson,
                serverIp: config.ip, // Valor dinâmico
                serverPort: config.port, // Valor dinâmico
                debugLabel: 'Calibração ATACANTE',
              );
            },
          ),
          // Botão de Configuração
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showConfigDialog(context),
          ),
          // Botão de Debug JSON
          IconButton(
            icon: const Icon(Icons.code),
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
                (value) => _updateAndSave(() => estado["kp"] = value),
              ),
              _buildCalibration(
                "Kd",
                estado["kd"],
                (value) => _updateAndSave(() => estado["kd"] = value),
              ),
              _buildCalibration("pwm", estado["pwm"],
                  (value) => _updateAndSave(() => estado["pwm"] = value)),
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
                _updateAndSave(() {
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
              _updateAndSave(() {
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
