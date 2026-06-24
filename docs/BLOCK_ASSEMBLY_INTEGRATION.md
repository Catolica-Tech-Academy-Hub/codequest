## Block Assembly Challenge - Documentação de Integração

### Visão Geral

O desafio de montagem lógica por blocos (`block_assembly`) é uma feature que permite aos usuários montar uma sequência correta de blocos lógicos mediante Drag & Drop.

**Entrega:**
- ✅ Biblioteca Drag & Drop funcional
- ✅ Áreas de destino com feedback visual
- ✅ Sistema de tentativas com limite configurável
- ✅ Integração com XP (recompensas e bônus)
- ✅ Validação inteligente com feedback detalhado

---

### Arquitetura

Segue **Clean Architecture por feature** com 5 camadas:

```
lib/features/block_assembly/
  ├── domain/
  │   ├── entities/          # LogicBlock, AssemblyChallenge, AssemblyAttempt
  │   ├── value_objects/     # BlockId, BlockLabel
  │   ├── errors/            # BlockAssemblyError e subclasses
  │   └── repositories/      # BlockAssemblyRepositoryContract
  ├── data/
  │   ├── dtos/              # Mapeamento Firestore ↔ Entities
  │   ├── repositories/      # BlockAssemblyRepository (Firebase)
  │   └── sources/           # (Futuro: local cache com Hive)
  ├── application/
  │   └── actions/           # Use cases (ValidateAssembly, SubmitAttempt)
  ├── providers/             # Riverpod (DI + estado)
  └── presentation/
      ├── block_assembly_page.dart     # Tela principal
      ├── controllers/       # AssemblyBoardNotifier
      └── widgets/           # DraggableLogicBlock, DropZone, Feedback
```

**Princípios:**
- Domínio: ZERO dependências de Firebase/Flutter
- Data: ÚNICO lugar que importa Firestore
- Application: Orquestra casos de uso
- Providers: Riverpod como DI e estado local
- Presentation: Apenas renderização + disparo de ações

---

### Como Usar

#### 1. Navegar para a Tela do Desafio

```dart
import 'package:codequest/features/block_assembly/presentation/block_assembly_page.dart';

// No GoRouter ou ao clicar em um desafio:
context.push('/challenge/block-assembly/${challengeId}',
  extra: {'userId': currentUserId},
);

// Ou diretamente:
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => BlockAssemblyPage(
      challengeId: 'desafio-001',
      userId: 'user-123',
    ),
  ),
);
```

#### 2. Submeter Dados Seed ao Firestore

```bash
# Seedar desafios de block assembly:
npm run seed --scope=codequest/firebase/seed
```

Estrutura esperada no Firestore:

```json
{
  "challenges": {
    "desafio-001": {
      "id": "desafio-001",
      "title": "Estrutura Básica do Dart",
      "description": "Monte a sequência correta de uma função Dart.",
      "difficulty": "easy",
      "xpReward": 50,
      "maxAttempts": 5,
      "blocks": [
        {
          "id": "block-main",
          "label": "void main() {",
          "expectedPosition": 0
        },
        {
          "id": "block-print",
          "label": "print('Hello');",
          "expectedPosition": 1
        },
        {
          "id": "block-close",
          "label": "}",
          "expectedPosition": 2
        }
      ]
    }
  }
}
```

---

### Fluxo Completo do Usuário

1. **Usuário acessa desafio** → `BlockAssemblyPage` carrega
2. **Vê blocos disponíveis** → renderizados via `DraggableLogicBlock`
3. **Arrasta blocos** → Riverpod atualiza `AssemblyBoardState`
4. **Solta em zonas** → `DropZone` aceita e chama `onAccept`
5. **Clica "Enviar"** → Chama `SubmitAssemblyAttemptUseCase`
6. **Use case valida** → `ValidateAssemblyUseCase` compara com esperado
7. **Salva tentativa** → Firebase armazena em `blockAssemblyAttempts`
8. **Atualiza progresso** → XP acrescido em `users/{uid}/challengeProgress`
9. **Exibe feedback** → `FeedbackOverlay` com resultado e XP ganho

---

### Sistema de Pontuação (XP)

**Regra:**
- Acerto na primeira tentativa: `xpReward + (xpReward / 5)` XP extra
- Acerto em tentativas posteriores: exato `xpReward`
- Erro: 0 XP

**Exemplo:**
```dart
// Desafio com xpReward: 50
// 1ª tentativa correta: 50 + 10 = 60 XP
// 2ª tentativa correta: 50 XP
```

O XP é:
1. Salvo em `blockAssemblyAttempts/{attemptId}.xpEarned`
2. Acrescido em `users/{uid}.totalXpEarned` (automático na data layer)
3. Displayado no feedback (`FeedbackOverlay`)

---

### Validação e Feedback

O `ValidateAssemblyUseCase` gera feedback específico:

```dart
// Bloco faltando
"Sequência incompleta. Esperado 3 blocos, recebido 2."

// Bloco errado em posição
"Bloco incorreto na posição 2. Você colocou "let x = 0", 
 mas deveria ser "const y = 1"."

// Sequência correta
"🎉 Parabéns! Você montou a sequência corretamente!"
```

---

### Tratamento de Erros (Domain Errors)

```dart
sealed class BlockAssemblyError implements Exception {
  // InvalidSequenceError → bloco inválido ou falha de validação
  // MaxAttemptsExceededError → limite de tentativas excedido
  // ChallengeNotAccessibleError → desafio não encontrado
  // RepositoryError → falha ao salvar no Firebase
}
```

---

### Testes

#### Teste Manual Local:

1. Inicialize infraestrutura:
   ```bash
   make infra-up
   npm run seed (dentro de firebase/seed)
   ```

2. Rode o app:
   ```bash
   flutter run
   ```

3. Acesse desafio:
   - Após login, navegue para `/challenge/block-assembly/desafio-001`

4. Teste Drag & Drop:
   - Arraste blocos da lista para as zonas
   - Valide feedback visual

---

### Estrutura de Dados (Firestore)

#### Collection: `challenges`
```
challenges/{challengeId}
├── id: String
├── title: String
├── description: String
├── blocks: Array<Block>
│   ├── id: String
│   ├── label: String
│   └── expectedPosition: int
├── xpReward: int
├── maxAttempts: int
└── difficulty: String ("easy" | "medium" | "hard")
```

#### Collection: `blockAssemblyAttempts`
```
blockAssemblyAttempts/{attemptId}
├── id: String
├── challengeId: String
├── userId: String
├── selectedBlockSequence: Array<String> (block IDs)
├── isCorrect: bool
├── attemptNumber: int
├── createdAt: Timestamp
├── xpEarned: int
└── feedback: String
```

#### Subcollection: `users/{uid}/challengeProgress/{challengeId}`
```
challengeProgress/{challengeId}
├── userId: String
├── challengeId: String
├── isCompleted: bool
├── attemptCount: int
├── totalXpEarned: int
├── lastAttemptAt: Timestamp?
└── firstCompletedAt: Timestamp?
```

---

### Extensões Futuras

1. **Animações avançadas** → Lottie para feedback
2. **Dificuldades dinâmicas** → Aumentar blocos baseado em nível
3. **Leaderboard** → Ranking por tempo de resolução
4. **Cache local** → Hive para offline (já estruturado em `data/sources/`)
5. **Análise de tentativas** → Dashboard de erros comuns
6. **Desafios multijogador** → Competição em tempo real

---

### Contribuição

Ao adicionar novos desafios:
1. Mantenha blocos claros e concisos
2. Defina `xpReward` adequado à dificuldade
3. Inclua descrição contextual
4. Seed os dados em `firebase/seed/seed.js`

---

**Status:** ✅ Feature completa e pronta para produção
