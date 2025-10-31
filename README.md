 **Aplicativo de Calibração do FHOBots** (Very Small Size Soccer - VSSS)

## 📝 Visão Geral do Projeto

O **Aplicativo de Calibração do FHOBots** é uma ferramenta desenvolvida para a equipe de Robótica FHOBots na categoria **Very Small Size Soccer (VSSS)** da IEEE.

Este aplicativo permite o ajuste dos parâmetros do controlador PID (`Kp`, `Kd`) e dos valores de PWM (Pulse-Width Modulation) para cada um dos robôs (**Atacante**, **Defensor** e **Goleiro**) em suas determinadas máquinas de estado.  
A calibração é enviada instantaneamente para a estação base via protocolo UDP (User Datagram Protocol).

---

## 🌟 Funcionalidades Principais

- **Calibração por Função:** Telas dedicadas para ajuste dos parâmetros do **Atacante**, **Defensor** e **Goleiro**.  
- **Ajuste por Estado:** Possibilidade de adicionar e ajustar `Kp`, `Kd` e `PWM` para diferentes estados de comportamento do robô (ex: `Attacking`, `Seeking`).  
- **Comunicação UDP:** Envio rápido e sem conexão dos dados de calibração em formato JSON.  
- **Persistência Local:** Os últimos valores de calibração são salvos no dispositivo, garantindo que não se percam entre as sessões.  
- **Configuração de Rede:** Possibilidade de alterar IP e Porta UDP antes do envio da mensagem, garantindo exatidão no envio corretamente e prevenção de manutenção para futuras mudanças nos endereços.

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
```
---

## ⚙️ Instalação e Uso
Pré-requisitos
Flutter SDK: Instale a versão mais recente do Flutter.

Dispositivo de Teste: Um emulador (Android Studios) ou dispositivo físico (Android ou iOS).

---

## 🚀 Configuração Rápida
- 1️⃣ Clone o Repositório.
   ```bash
    git clone https://github.com/FHOBots/fhobots-pid-calibrator.git
    cd fhobots-pid-calibrator
    ```
- 2️⃣ Instale as Dependências
```bash
   flutter pub get
```
- 3️⃣ Execute o Aplicativo
```bash
  flutter run
````
---

## 📡 Configurando a Conexão UDP
- Abra a tela de qualquer robô (Atacante, Defensor ou Goleiro).

-  Clique no ícone de Configurações (⚙️) na barra superior.

-  Insira o Endereço IP do servidor e a Porta UDP que está ouvindo os pacotes de calibração (obs: O aplicativo já é endereçado para um servidor especifico. Só altere essa configuração caso seja necessário).

-  Clique em Salvar.

---
## 🔧 Calibração
-  Navegue para a página do robô desejado.

-  Expanda o estado que deseja ajustar.

-  Insira os novos valores de Kp, Kd e PWM e pressione Enter para salvar localmente.

-  Clique no botão Enviar (✈️) na barra superior.
-  O aplicativo enviará o pacote JSON completo via UDP.

- Remova o estado selecionando o botão Remover (🗑️).

- Adcione um novo estado selecionando botão Adcionar estado (➕).

---

## 📷 Screenshots

<p align= center>
   <img src= "https://github.com/user-attachments/assets/a6e77f16-5187-488f-9c53-2ad53260de27">
</p>




---
<p align= center>
   <img src= "https://github.com/user-attachments/assets/68b434d9-941b-4ee1-9c84-281f6b21303c">
</p>


---

<p align= center>
   <img src= "https://github.com/user-attachments/assets/e77c5730-f6f0-4aee-90c8-41721d9827ba">
</p>



---

<p align= center>
   <img src= "https://github.com/user-attachments/assets/73e6204c-5429-4d46-8502-950b4dc018f6">
</p>



---

<p align= center>
   <img src= "https://github.com/user-attachments/assets/fd0c04f0-2de8-449d-bdab-e99d0d7fcf02">
</p>



---




