import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io'; // Essencial para File e Directory.systemTemp
import 'JsonSendWidget.dart'; // Mantenha, se necessário para UdpSendButton

// ------------------------------------------------------------------
// A LISTA DE ESTADOS É GLOBAL. Inicialmente vazia para forçar o carregamento
// do arquivo ou dos valores padrão no initState.
// ------------------------------------------------------------------
List<Map<String, dynamic>> goalkepperEstados = [];

// Lista de estados padrão para usar se o arquivo não existir ou falhar
const List<Map<String, dynamic>> _DEFAULT_ESTADOS = [
  {"nome": "MoveFoward", "kp": 0.0, "kd": 0.0, "pwm": 0.0},
  {"nome": "MoveBackward", "kp": 0.0, "kd": 0.0, "pwm": 0.0},
];
// ------------------------------------------------------------------

class GoalKepperPage extends StatefulWidget {
  const GoalKepperPage({super.key});

  @override
  State<GoalKepperPage> createState() => _GoalKepperPageState();
}

class _GoalKepperPageState extends State<GoalKepperPage> {
  // ------------------------------------------------------------------
  // CONFIGURAÇÃO DO SERVIDOR UDP
  // ------------------------------------------------------------------
  static const String serverIp =
      '192.168.1.102'; // Mude para o IP da sua máquina Windows/servidor
  static const int serverPort = 8888; // Porta configurada no servidor C++
  // ------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadEstados(); // Tenta carregar os dados persistidos
  }

// #################### Funções de Persistência (Arquivo JSON - TEMPORÁRIO) ####################

// 1. Obtém o caminho do arquivo no diretório TEMPORÁRIO do sistema.
  Future<File> get _localFile async {
    final directory = Directory.systemTemp;
    return File('${directory.path}/goalkepper_config.json');
  }

// 2. Salva a lista de estados no arquivo como JSON.
  Future<void> _saveEstados() async {
    final file = await _localFile;
    final jsonString = jsonEncode(goalkepperEstados);
    await file.writeAsString(jsonString);
  }

// 3. Carrega a lista de estados do arquivo, usando o padrão se falhar.
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

        // Assume sucesso se carregou algo
        success = estadosCarregados.isNotEmpty;
      }
    } catch (_) {
      // Falhou em carregar/decodificar. Success continua 'false'.
    }

    if (!success) {
      // Se falhou, usa a cópia da lista padrão
      estadosCarregados =
          _DEFAULT_ESTADOS.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    // Atualiza o estado
    setState(() {
      goalkepperEstados = estadosCarregados;
    });

    // Se usou o padrão (ou falhou), salva para recriar o arquivo temporário
    if (!success) {
      await _saveEstados();
    }
  }

// Método auxiliar para chamar setState e salvar o arquivo
  void _updateAndSave(VoidCallback updateCallback) {
    setState(() {
      updateCallback();
    });
    _saveEstados(); // Salva o novo estado após a alteração
  }

  // #################### Fim das Funções de Persistência ####################

  // Função para gerar o mapa no formato JSON
  Map<String, dynamic> _generateJson() {
    final Map<String, dynamic> goalkepperData = {};

    for (final estado in goalkepperEstados) {
      final key = estado["nome"].toString();

      goalkepperData[key] = {
        "kp": estado["kp"],
        "kd": estado["kd"],
        "pwm": estado["pwm"],
      };
    }

    return {"Goleiro": goalkepperData};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("goalkepper - Calibration"),
        centerTitle: true,
        actions: [
          // Widget que envia o JSON via UDP
          UdpSendButton(
            jsonGenerator:
                _generateJson, // Passa a referência da função geradora
            serverIp: serverIp,
            serverPort: serverPort,
            debugLabel: 'Calibração Goalkepper',
          ),
          IconButton(
            icon: const Icon(Icons.code), // Botão de debug para ver o JSON
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
      body: goalkepperEstados.isEmpty && mounted
          ? const Center(child: CircularProgressIndicator()) // Mostra loading
          : ListView.builder(
              itemCount: goalkepperEstados.length,
              itemBuilder: (context, index) {
                final estado = goalkepperEstados[index];
                return ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(estado["nome"]),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        // Chama a função que leva ao _updateAndSave
                        onPressed: () => _confirmarDelete(index),
                      ),
                    ],
                  ),
                  children: [
                    _buildCalibration(
                      "Kp",
                      estado["kp"],
                      // Usa _updateAndSave para persistir a alteração
                      (value) => _updateAndSave(() => estado["kp"] = value),
                    ),
                    _buildCalibration(
                      "Kd",
                      estado["kd"],
                      // Usa _updateAndSave para persistir a alteração
                      (value) => _updateAndSave(() => estado["kd"] = value),
                    ),
                    _buildCalibration(
                        "pwm",
                        estado["pwm"],
                        // Usa _updateAndSave para persistir a alteração
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
                  onChanged(parsed); // Chama _updateAndSave
                }
                // Garante que o campo de texto exiba o valor formatado
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
                  // Chama _updateAndSave
                  goalkepperEstados
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
          "Are you sure you want to remove the state '${goalkepperEstados[index]["nome"]}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _updateAndSave(() {
                // Chama _updateAndSave
                goalkepperEstados.removeAt(index);
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
