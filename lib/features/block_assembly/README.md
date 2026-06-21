# Block Assembly Challenge Feature

Desafio de montagem lógica por blocos com Drag & Drop, integração com XP e sistema de tentativas.

## 🎯 O que é?

Um tipo de desafio educacional onde o usuário ordena blocos de código/lógica para montar uma sequência correta, aprendendo estrutura de linguagens de programação de forma interativa.

## 📂 Estrutura

```
domain/           → Entidades, value objects, contratos (sem dependências externas)
data/             → Firestore implementation, DTOs
application/      → Use cases (validação, submissão)
providers/        → Riverpod (DI + estado)
presentation/     → Tela, widgets, controllers
```

## 🚀 Uso Rápido

### Navegar para Desafio

```dart
context.push('/challenge/block-assembly/$challengeId', extra: userId);
```

### No Router

```dart
GoRoute(
  path: '/challenge/block-assembly/:challengeId',
  builder: (context, state) => BlockAssemblyPage(
    challengeId: state.pathParameters['challengeId']!,
    userId: FirebaseAuth.instance.currentUser!.uid,
  ),
),
```

## 🎮 Fluxo do Usuário

1. **Vê desafio** com descrição e número de blocos
2. **Arrasta blocos** da lista para posições numeradas
3. **Recebe feedback** visual (bloco correto/incorreto)
4. **Submete** quando completo
5. **Ganha XP** + feedback de sucesso/erro

## 📊 Dados (Firestore)

```
challenges/{challengeId}
├── title, description, difficulty
├── blocks: [{id, label, expectedPosition}]
├── xpReward: int
└── maxAttempts: int

users/{uid}/challengeProgress/{challengeId}
├── isCompleted, attemptCount, totalXpEarned
└── timestamps

blockAssemblyAttempts/{attemptId}
├── userId, challengeId, selectedBlockSequence
├── isCorrect, feedback, xpEarned
└── createdAt
```

## 🧪 Testes

```bash
flutter test test/features/block_assembly/
```

## 📖 Documentação

- [INTEGRATION](./presentation/ROUTER_INTEGRATION.dart) — Setup no router
- [FULL DOCS](../docs/BLOCK_ASSEMBLY_INTEGRATION.md) — Documentação completa
- [SUMMARY](../docs/BLOCK_ASSEMBLY_SUMMARY.md) — Sumário com checklist

## 🔧 Seed de Dados

```bash
cd firebase/seed
node block_assembly_seed.js
```

Ou integre em `seed.js`:
```js
const { seedBlockAssemblyChallenges } = require('./block_assembly_seed.js');
await seedBlockAssemblyChallenges();
```

## 💡 Exemplos de Desafios

- **Easy:** Estrutura básica Dart (3 blocos)
- **Medium:** Ciclo de vida StatefulWidget (5 blocos)
- **Hard:** Try-catch com exceções (5 blocos)

## 🎨 Customizar

### Mudar cores

Em qualquer widget, use `Theme.of(context).colorScheme`

### Modificar XP

Em `validate_assembly_use_case.dart`, ajuste:
```dart
final xpBonus = attemptNumber == 1 ? challenge.xpReward ~/ 5 : 0;
```

### Adicionar novo desafio

1. Crie documento em `challenges/novo-id`
2. Configure `blocks`, `xpReward`, `maxAttempts`
3. Seed ao Firestore

## 🐛 Troubleshooting

**Blocos não arrastam?**
→ Verificar `Draggable` é filho de `Material`

**XP não atualiza?**
→ Verificar Firestore rules e `users/{uid}` existe

**Feedback não mostra?**
→ Verificar `showDialog` envolvendo `FeedbackOverlay`

## 📝 Conventions

- **Domain:** Sem Firebase/Flutter imports
- **Data:** ÚNICO lugar com `cloud_firestore`
- **Application:** Orquestra use cases
- **Presentation:** Apenas UI + dispara ações

---

**Status:** ✅ Pronto para produção  
**Última atualização:** 2026-06-16
