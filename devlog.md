### 5/03

#### Henrique (10:00 ~ 11:00)
 1. Escrevendo documento e tentativas de porte para 3.0

#### Henrique (16:00 ~ 17:30)
 1. Porte para 3.0

### 08/03

#### Arthur
 1. Criação do repositório.

#### Henrique (13:00 ~ 14:00)
 1. Terminando documento e criando repositório

#### Henrique (16:00 ~ 18:00)
 1. Consertando controles e cenas/scripts quebrados
 2. Entendendo melhor process e fixed process

### 12/03

#### Henrique (10:00 ~ 11:30)
 1. Porte de quase todas as magias completo (leafshield e watersplash faltando)

### 14/03

#### Henrique (14:00 ~ 15:30)
 1. Terminando de portar as cenas das magias que faltavam e revivendo fixed process no personagem

### 15/03

#### Arthur (13:30 ~ 20:30)
 1. Criação de um novo projeto da Godot para reorganização de pastas e cenas.
 2. Importação das cenas do projeto antigo que podiam ser reutilizadas.
 3. Início da refatoração de código do personagem.

### 18/03

#### Henrique (13:00 ~ 15:00)
 1. Ajustando controles de teclado para funcionarem sem o script de input_states
 2. Tentando migrar cenas do projeto antigo, mas sem sorte em tudo além de firebolt

### 19/03

#### Henrique (10:00 ~ 11:30)
 1. Migrando com sucesso cenas e scripts de magias do projeto antigo

#### Arthur (16:00 ~ 20:00)
 1. Continuação da refatoração do personagem.
 2. Reorganização do código e estrutura de cenas das magias.

### 26/03

#### Henrique (13:00 ~ 15:30)
 1. Consertando alguns bugs em timers
 2. Bindings para controles e teclas
 3. Entendendo melhor Node2D e KinematicBody2D
 4. Entendendo melhor telas de menu

### 27/03

#### Henrique (14:30 ~ 17:00)
 1. Criando assets basicos para menu
 2. Criando cena de menu principal e conectando com cena de teste

### 02/04

#### Henrique (10:00 ~ 11:30)
 1. Refatorando mais spells e consertando bugs

### 04/04

#### Henrique (15:00 ~ 17:30)
 1. Revivendo controles de teclado para dois jogadores
 2. Mapeando inputs para dois controles, ainda não testado
 3. Redimensionamento de sprites de personagem, agora abrem bem mais rapido
 4. Fade-in e fade-out no menu
 5. Outros ajustes, mais detalhes no commit de hoje

### 07/04

#### Henrique (11:00 ~ 12:00)
 1. Iédia báscia de dash implementada (dash = shift/control)
 2. Spells de fogo não afetam personagens no meio de dash

### 12/04

#### Arthur (16:30 ~ 18:30)
 1. Padronização dos tempos de charge e cooldown das magias.
 2. Conserto das animações de desaparecer das magias de fogo.
 3. Início da refatoração das magias de água.

### 14/04

#### Henrique (10:30 ~ 14:00)
 1. Character Select Screen em progresso
 2. Tela de pause implementada, com opção de retornar ao menu

### 16/04

#### Henrique (10:00 ~ 11:30)
 1. CSS não permite dois players selecionarem o mesmo personagem (não testado)
 2. Opção de player "sair" da tela/desselecionar personagem

### 18/04

#### Henrique (13:30 ~ 16:30)
 1. Tela de pause reinserida (aparentemente nao comitei sem querer)
 2. Novas animações na CSS de entrada e saida
 3. Correções no comportamento da CSS
 4. Transição da CSS para batalha em andamento
 5. Alguns esboços de personagens

### 19/04

#### Arthur (16:30 ~ 19:30)
 1. Refatoração das magias de água e eletricidade.

### 21/04

#### Henrique (18:15 ~ 21:00)
 1. Raio lv2 é castada sem mostrar o raio logo de cara
 2. CSS detecta teclado e o diferencia do primeiro controle antes conflitado
 3. Leve refatoração no código da CSS
 4. Remapeamento de inputs, agora baseados em device ao invés de player
 5. Cena de batalha agora inicia os jogadores na posição e com skin certas
 6. Código obsoleto removido do script do personagem

### 23/04

#### Henrique (10:00 ~ 11:30)
 1. Play no main menu leva para CSS
 2. Adicionadas variaveis globais para mais facil instanciamento da batalha
 3. Battle.tscn agora é independente da CSS
 4. Condição de vitória adicionada na batalha
 5. Tela de pause agora é uma cena para mais facil instanciamento na batalha

### 25/04

#### Henrique (15:10 ~ 18:00)
 1. Refatoração do main menu
 2. Tela de pause despausa quando der quit
 3. Battle instancia cena de pause por código e por ultimo, para ela ficar em cima de tudo
 4. Input map de UI para devices restantes
 5. Sprites de personagens restantes redimensionados
 6. Minor bug fixes para show-off amanhã >:D

### 26/04

#### Arthur (16:00 ~ 20:30)
 1. Refatoração da magia de natureza nível 1.
 2. Polimento de algumas animações e partículas.

### 30/04

#### Henrique (14:30 ~ 17:00)
 1. Conserto de bugs
 2. Barra e texto de indicação de tempo de stun, slow, root
 3. Cena de floresta praticamente pronta, com objetos (arvore e pedra)

### 01/05

#### Henrique (15:50 ~ 19:00)
 1. Visual rehaul da charge bar e cooldown bar
 2. Conserto de bug em fire3

### 04/05

#### Henrique (17:00 ~ 19:00)
 1. Status bar e status label deletadas
 2. Novas sprites de indicação de status (slow, stun e root)

### 07/05

#### Henrique (10:10 ~ 11:20)
 1. Pequenos consertos de bugs
 2. Inicio de implementação da tela de seleção de fases

### 10/05

#### Henrique (15:30 ~ 17:20)
 1. Resize em sprites de charge bar/cooldown bar
 2. Progresso na stage select screen
 3. Suporte para controle para mover cursor
 4. CSS passa para stage select screen ao invés de ir direto para forest