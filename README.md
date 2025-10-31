 🤖 FHOBots PID Calibrator App (Very Small Size Soccer - VSSS)

## 📝 Visão Geral do Projeto

O **FHOBots PID Calibrator App** é uma ferramenta móvel essencial desenvolvida para a equipe de Robótica **FHOBots** na categoria **Very Small Size Soccer (VSSS)** da IEEE.

Este aplicativo permite o **ajuste fino e em tempo real** dos parâmetros do controlador **PID** (`Kp`, `Kd`) e dos valores de **PWM** (Pulse-Width Modulation) para cada um dos robôs (**Atacante**, **Defensor** e **Goleiro**).  
A calibração é enviada instantaneamente para a estação base via protocolo **UDP** (User Datagram Protocol), otimizando o ciclo de ajuste de controle em campo.

---

## 🌟 Funcionalidades Principais

- **Calibração por Função:** Telas dedicadas para ajuste dos parâmetros do **Atacante**, **Defensor** e **Goleiro**.  
- **Ajuste por Estado:** Possibilidade de adicionar e ajustar `Kp`, `Kd` e `PWM` para diferentes estados de comportamento do robô (ex: `Attacking`, `Seeking`).  
- **Comunicação UDP:** Envio rápido e sem conexão dos dados de calibração em formato JSON.  
- **Persistência Local:** Os últimos valores de calibração são salvos no dispositivo, garantindo que não se percam entre as sessões.  
- **Configuração de Rede:** Diálogo para configuração rápida do IP e Porta UDP do servidor de recebimento.

---

## 💻 Detalhes Técnicos

| Categoria | Detalhe |
| :--- | :--- |
| **Framework Principal** | Flutter |
| **Linguagem** | Dart |
| **Comunicação** | UDP (User Datagram Protocol) |
| **Formato de Dados** | JSON (codificado via `dart:convert`) |
| **Persistência** | Arquivo temporário (`dart:io`) para salvar calibrações |

---

### 🧩 Estrutura de Comunicação

Os dados são empacotados em um objeto JSON contendo o nome do robô, e dentro dele, os parâmetros de `Kp`, `Kd` e `PWM` para cada estado definido.

**Exemplo de JSON Gerado:**

```json
{
  "Attacker": {
    "Attacking": {
      "kp": 0.5,
      "kd": 0.1,
      "pwm": 150.0
    },
    "Seeking": {
      "kp": 0.3,
      "kd": 0.05,
      "pwm": 120.0
    }
  }
}
⚙️ Instalação e Uso
Pré-requisitos
Flutter SDK: Instale a versão mais recente do Flutter.

Dispositivo de Teste: Um emulador ou dispositivo físico (Android ou iOS).

🚀 Configuração Rápida
1️⃣ Clone o Repositório
bash
Copiar código
git clone https://github.com/FHOBots/fhobots-pid-calibrator.git
cd fhobots-pid-calibrator
2️⃣ Instale as Dependências
bash
Copiar código
flutter pub get
3️⃣ Execute o Aplicativo
bash
Copiar código
flutter run
📡 Configurando a Conexão UDP
Abra a tela de qualquer robô (Atacante, Defensor ou Goleiro).

Clique no ícone de Configurações (⚙️) na barra superior.

Insira o Endereço IP (geralmente o IP da estação base ou do robô) e a Porta UDP que está ouvindo os pacotes de calibração.

Clique em Salvar.

🔧 Calibração
Navegue para a página do robô desejado.

Expanda o estado que deseja ajustar.

Insira os novos valores de Kp, Kd e PWM e pressione Enter para salvar localmente.

Clique no botão Enviar (📤) na barra superior.
O aplicativo enviará o pacote JSON completo via UDP.
