import 'package:appcalibracao/appControler.dart';
import 'package:appcalibracao/attackerPage.dart';
import 'package:appcalibracao/defenderPage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() {
    return homePageState();
  }
}

class homePageState extends State<HomePage> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FHOBots Calibração"),
        centerTitle: true,
        actions: [CustomSwitch()],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AttackerPage()));
                // Aqui você pode navegar para a tela do Atacante
                print("Atacante selecionado");
              },
              child: const Text("Atacante"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DefenderPage()));
                // Aqui você pode navegar para a tela do Atacante
                print("Defender selecionado");
              },
              child: const Text("Defensor"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aqui você pode navegar para a tela do Goleiro
                print("Goleiro selecionado");
              },
              child: const Text("Goleiro"),
            ),
          ],
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
