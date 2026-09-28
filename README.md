# Airsoft Simulator (Airsoft_magnus_effect)

Um simulador de Airsoft focado em mecânicas realistas, incluindo sistema de Hopup (efeito Magnus), balística e gerenciamento de carregadores.

## 🚀 Como iniciar o jogo no Godot

1. Certifique-se de ter o **Godot Engine 4.x** instalado.
2. Abra o Godot Engine, clique no botão **Importar** (Import).
3. Navegue até a pasta onde este projeto se encontra e selecione o arquivo `project.godot`.
4. Com o projeto aberto no editor, pressione a tecla **F5** (ou clique no ícone de "Play" no canto superior direito) para rodar o jogo. A cena principal configurada para iniciar é o Menu Principal (`res://scenes/main_menu.tscn`).

## 🎮 Como Jogar (Controles e Mecânicas)

### 🚶‍♂️ Movimentação
* **W, A, S, D:** Movimentar o personagem.
* **Shift:** Correr.
* **Espaço:** Pular.
* **Q:** Inclinar corpo para a esquerda (Leaning).
* **E:** Inclinar corpo para a direita / Interagir (Coletar itens do cenário, como carregadores de munição).

### 🔫 Armas e Combate
* **Botão Esquerdo do Mouse:** Atirar.
* **Botão Direito do Mouse:** Mirar (Scope/ADS).
* **R:** Recarregar a arma (consome carregadores reservas do seu inventário).
* **F:** Alternar modo de disparo (SEMI / AUTO) - disponível nas armas que suportam.
* **1, 2, 3, 4:** Trocar de arma:
  * `1`: Rifle
  * `2`: Shotgun
  * `3`: Sniper
  * `4`: Pistola
* **Scroll do Mouse (Cima/Baixo):** Ajustar o **Hopup**. Aumentar ou diminuir o Hopup muda o RPM de backspin da munição, afetando sua sustentação no ar por conta do Efeito Magnus.

### 🖥️ Interface e Sistema
* **ESC:** Travar / Destravar o cursor do mouse na tela.
* **Backspace:** Voltar ao Menu Principal (disponível quando estiver jogando no modo Treino).

## ⚙️ Modos de Jogo e Configurações

No Menu Principal, você pode escolher opções como:
* **Dificuldade:** Fácil, Médio ou Difícil.
* **Modos de Jogo:**
  * **Treino:** Jogue sem limite de tempo para praticar seus tiros e ajustes de Hopup.
  * **Quick (60s):** Partida rápida com limite de 60 segundos para tentar obter a maior pontuação possível atirando nos alvos. O seu recorde é salvo e exibido no menu!
  * **Tempo Custom:** Escolha livremente quanto tempo a partida deverá durar.