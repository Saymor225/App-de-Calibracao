import 'package:appcalibracao/appControler.dart';
import 'package:appcalibracao/attackerPage.dart';
import 'package:appcalibracao/defenderPage.dart';
import 'package:appcalibracao/goalkepperPage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() {
    return homePageState();
  }
}

class homePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ⚠️ IMPORTANTE: Deixa o corpo do Scaffold ser desenhado atrás da AppBar
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text("FHOBots Calibração"),
        centerTitle: true,
        actions: [CustomSwitch()],
        backgroundColor:
            Colors.transparent, // AppBar transparente para ver o fundo
        elevation: 0, // Remove a sombra da AppBar
      ),

      // SUBSTITUIÇÃO: O body agora é o Container com a imagem
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 2, 2, 2),
          image: DecorationImage(
              // ⚠️ Verifique se o caminho 'assets/FHOBots_logo_2023.png' está correto
              // Use 'const' se o caminho for estático para otimização
              image: AssetImage('assets/Background.png'),
              fit: BoxFit.contain,
              alignment: Alignment.center),
        ),

        // O CONTEÚDO ORIGINAL DA SUA TELA VAI AQUI (O Column com os botões)
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(240, 80),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AttackerPage()));
                  print("Atacante selecionado");
                },
                child: const Text("Atacante", style: TextStyle(fontSize: 20.0)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(240, 80),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => DefenderPage()));
                  print("Defensor selecionado");
                },
                child: const Text("Defensor", style: TextStyle(fontSize: 20.0)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(240, 80),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => GoalKepperPage()));
                  print("Goleiro selecionado");
                },
                child: const Text("Goleiro", style: TextStyle(fontSize: 20.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Switch(
        value: appControler.instance.darkTheme,
        onChanged: (value) {
          appControler.instance.changeTheme();
        });
  }
}
