import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io'; // Importante para File e Directory.systemTemp
import 'JsonSendWidget.dart'; // Necessário para RawDatagramSocket e InternetAddress

// ------------------------------------------------------------------
// A LISTA DE ESTADOS É GLOBAL E PERSISTENTE PARA O DEFENDER
// Mude para uma lista vazia, o estado padrão será aplicado no _loadEstados()
// ------------------------------------------------------------------
List<Map<String, dynamic>> defenderEstados = [];

// Lista de estados padrão para usar se o arquivo não existir ou falhar
const List<Map<String, dynamic>> _DEFENDER_DEFAULT_ESTADOS = [
  {"nome": "Kicking", "kp": 0.0, "kd": 0.0, "pwm": 0.0},
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
  // CONFIGURAÇÃO DO SERVIDOR UDP PARA O DEFENDER
  // ------------------------------------------------------------------
  static const String serverIp = '192.168.1.102';
  static const int serverPort = 8888;
  // ------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadEstados(); // Tenta carregar os dados salvos ao iniciar a tela
  }

  // #################### Funções de Persistência (Arquivo JSON - TEMPORÁRIO) ####################

  // 1. Obtém o caminho do arquivo no diretório TEMPORÁRIO do sistema.
  Future<File> get _localFile async {
    // Usando Directory.systemTemp para evitar path_provider
    final directory = Directory.systemTemp;
    // Usando um nome de arquivo específico para o Defender
    return File('${directory.path}/defender_config.json');
  }

  // 2. Salva a lista de estados no arquivo como JSON.
  Future<void> _saveEstados() async {
    try {
      final file = await _localFile;
      final jsonString = jsonEncode(defenderEstados);
      await file.writeAsString(jsonString);
    } catch (_) {
      // Ignora erros de salvamento para simplificar e evitar travar
    }
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

        success = estadosCarregados.isNotEmpty;
      }
    } catch (_) {
      // Falhou em carregar/decodificar. Success continua 'false'.
    }

    if (!success) {
      // Se falhou, usa a cópia da lista padrão
      estadosCarregados = _DEFENDER_DEFAULT_ESTADOS
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    // Atualiza o estado global e a UI
    setState(() {
      defenderEstados = estadosCarregados;
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
    final Map<String, dynamic> defenderData = {};

    for (final estado in defenderEstados) {
      final key = estado["nome"].toString();

      defenderData[key] = {
        "kp": estado["kp"],
        "kd": estado["kd"],
        "pwm": estado["pwm"],
      };
    }

    // A chave principal é "Defender"
    return {"Defender": defenderData};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Defender - Calibration"),
        centerTitle: true,
        actions: [
          UdpSendButton(
            jsonGenerator: _generateJson,
            serverIp: serverIp,
            serverPort: serverPort,
            debugLabel: 'Calibração DEFENDER',
          ),
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () {
              final jsonString = jsonEncode(_generateJson());
              print("--- JSON Defender Gerado ---");
              print(jsonString);
              print("--------------------------");

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('JSON Defender copiado para o console.')),
              );
            },
          ),
        ],
      ),
      body: defenderEstados.isEmpty && mounted
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: defenderEstados.length,
              itemBuilder: (context, index) {
                final estado = defenderEstados[index];
                return ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(estado["nome"]),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        // Chama o método que salva
                        onPressed: () => _confirmarDelete(index),
                      ),
                    ],
                  ),
                  children: [
                    _buildCalibration(
                      "Kp",
                      estado["kp"],
                      // Usa _updateAndSave
                      (value) => _updateAndSave(() => estado["kp"] = value),
                    ),
                    _buildCalibration(
                      "Kd",
                      estado["kd"],
                      // Usa _updateAndSave
                      (value) => _updateAndSave(() => estado["kd"] = value),
                    ),
                    _buildCalibration(
                        "pwm",
                        estado["pwm"],
                        // Usa _updateAndSave
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
        title: const Text("New Defender State"),
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
                  defenderEstados
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
        title: const Text("Remove Defender State"),
        content: Text(
          "Are you sure you want to remove the state '${defenderEstados[index]["nome"]}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _updateAndSave(() {
                defenderEstados.removeAt(index);
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
