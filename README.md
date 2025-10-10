# Aplicativo de Calibração de PID para Categoria IEEE Very Small Size

Irei gerar o README completo, baseado no código que você forneceu e nas premissas comuns a projetos de calibração de robôs via Wi-Fi (como uso de HTTP e um dispositivo microcontrolador como servidor).

Você pode copiar e colar o texto abaixo no seu arquivo `README.md`.

-----

# 🤖 Attacker Calibration App (Configuração do Robô Atacante)

## Visão Geral do Projeto

Este projeto é um aplicativo Flutter desenvolvido para funcionar como uma interface de calibração dinâmica para um robô atacante. Ele permite que engenheiros ou usuários ajustem, em tempo real, os parâmetros de controle (Kp, Kd e PWM) para diferentes estados de comportamento do robô (como "Seeking" e "Attacking"), e envie esses dados via Wi-Fi para o dispositivo do robô.

O objetivo é simplificar o processo de ajuste fino de controle PID e lógica de movimento sem a necessidade de reprogramação constante do hardware do robô.

## ✨ Funcionalidades

  * **Calibração Dinâmica de Estados:** Ajuste e armazene parâmetros Kp, Kd e PWM para múltiplos estados definidos.
  * **Gestão de Estados:** Adicione novos estados de calibração e remova estados existentes.
  * **Persistência de Dados:** Os valores de calibração persistem no aplicativo (usando uma variável global) mesmo após a navegação de saída e retorno à tela.
  * **Envio via Wi-Fi (HTTP POST):** Envie todos os parâmetros de calibração empacotados em JSON para um endereço de servidor/robô configurado.
  * **Feedback Visual:** Recebe notificações (SnackBar) sobre o sucesso ou falha na tentativa de conexão e envio de dados.

## ⚙️ Tecnologias Utilizadas

  * **Frontend:**
      * [**Flutter SDK**](https://flutter.dev/): Framework para desenvolvimento do aplicativo móvel.
      * **Dart:** Linguagem de programação.
      * **Pacote `http`:** Utilizado para realizar a comunicação via rede (requisições HTTP POST).
  * **Comunicação:**
      * **Protocolo:** HTTP POST
      * **Formato de Dados:** JSON

## 🛠️ Instalação e Configuração

### Pré-requisitos

1.  Flutter SDK instalado e configurado.
2.  Um ambiente de desenvolvimento (VS Code ou Android Studio).
3.  O servidor/robô deve estar configurado para criar um Ponto de Acesso Wi-Fi ou estar na mesma rede que o dispositivo móvel.

### Configuração do App

O endereço do servidor que recebe os dados é definido dentro do arquivo `attacker_page.dart`.

Certifique-se de que os seguintes valores correspondem à configuração do seu robô (ex: ESP32 ou Raspberry Pi):

```dart
// attacker_page.dart (dentro da classe _AttackerPageState)
static const String serverIp = '192.168.4.1'; // IP padrão de Access Points de microcontroladores
static const String serverPort = '80';       // Porta padrão HTTP
static const String endpoint = '/calibration'; // Caminho que o servidor escuta
```

## 📡 Detalhes da Comunicação e Formato JSON

O aplicativo faz uma requisição **HTTP POST** para o `URL: http://[serverIp]:[serverPort]/calibration`.

O *header* da requisição é definido como `Content-Type: application/json`.

O corpo da requisição é um objeto JSON que contém todos os estados de calibração e seus respectivos parâmetros, seguindo o formato:

```json
{
  "atacante": {
    "Attacking": {
      "kp": 0.5,
      "kd": 0.1,
      "pwm": 200.0
    },
    "Seeking": {
      "kp": 0.2,
      "kd": 0.05,
      "pwm": 150.0
    },
    "NovoEstado": {
      "kp": 0.0,
      "kd": 0.0,
      "pwm": 0.0
    }
  }
}
```

**Nota para o Desenvolvedor do Servidor:** O servidor deve ser capaz de receber e parsear este objeto JSON, extraindo os valores `kp`, `kd` e `pwm` para cada estado (`Attacking`, `Seeking`, etc.) e aplicá-los à lógica de controle do robô.

## 📝 Como Usar o Aplicativo

1.  **Ajustar Parâmetros:** Expanda cada estado (`Attacking`, `Seeking`, etc.) e insira os novos valores Kp, Kd e PWM nos campos de texto. Use a tecla **Enter** ou **Submeter** do teclado para confirmar e salvar o novo valor no estado do aplicativo.
2.  **Adicionar/Remover:** Use o botão flutuante **(+)** para criar novos estados de calibração ou o **ícone de lixo** (🗑️) para remover um estado existente.
3.  **Enviar para o Robô:** Clique no **ícone de Envio** (↗️) na `AppBar`.
      * O aplicativo tentará enviar o JSON para o endereço configurado.
      * Uma notificação aparecerá para indicar se o envio foi bem-sucedido (`200 OK`) ou se houve falha de conexão ou erro do servidor.
4.  **Visualizar JSON (Debug):** O **ícone de Código** (`<>`) na `AppBar` imprimirá a string JSON gerada no console de debug do Flutter (útil para verificar o formato exato antes de enviar).

## ⚠️ Dependências Externas

Certifique-se de que a dependência HTTP está corretamente configurada no seu `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.6 # Garanta que o pacote http está presente
```
