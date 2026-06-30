/**
 * Seed de desafios de Block Assembly para Firebase
 *
 * Exemplos de desafios de montagem lógica por blocos
 * com dificuldades variadas.
 */

const blockAssemblyChallenges = [
  {
    id: 'block-assembly-dart-main',
    title: 'Estrutura Básica do Dart',
    description: 'Monte a sequência correta de uma função Dart básica.',
    difficulty: 'easy',
    xpReward: 30,
    maxAttempts: 5,
    blocks: [
      { id: 'block-void-main', label: 'void main() {', expectedPosition: 0 },
      { id: 'block-print', label: "print('Hello, Dart');", expectedPosition: 1 },
      { id: 'block-close-brace', label: '}', expectedPosition: 2 },
    ],
  },
  {
    id: 'block-assembly-flutter-state',
    title: 'Ciclo de Vida StatefulWidget',
    description: 'Ordene o fluxo correto de um StatefulWidget em Flutter.',
    difficulty: 'medium',
    xpReward: 50,
    maxAttempts: 4,
    blocks: [
      { id: 'block-class-state', label: 'class MyState extends State {', expectedPosition: 0 },
      { id: 'block-init-state', label: '@override void initState() { super.initState(); }', expectedPosition: 1 },
      { id: 'block-build', label: '@override Widget build(BuildContext context) {', expectedPosition: 2 },
      { id: 'block-return-widget', label: 'return Scaffold(...);', expectedPosition: 3 },
      { id: 'block-close-brace-2', label: '}', expectedPosition: 4 },
    ],
  },
  {
    id: 'block-assembly-conditional',
    title: 'Estrutura de Condicional Dart',
    description: 'Monte a sequência correta de um bloco if-else em Dart.',
    difficulty: 'medium',
    xpReward: 40,
    maxAttempts: 4,
    blocks: [
      { id: 'block-if', label: 'if (idade >= 18) {', expectedPosition: 0 },
      { id: 'block-print-adult', label: "print('Você é maior de idade');", expectedPosition: 1 },
      { id: 'block-else', label: '} else {', expectedPosition: 2 },
      { id: 'block-print-minor', label: "print('Você é menor de idade');", expectedPosition: 3 },
      { id: 'block-close-brace-3', label: '}', expectedPosition: 4 },
    ],
  },
  {
    id: 'block-assembly-for-loop',
    title: 'Loop For Completo',
    description: 'Ordene os componentes corretos de um loop for em Dart.',
    difficulty: 'hard',
    xpReward: 60,
    maxAttempts: 3,
    blocks: [
      { id: 'block-for-init', label: 'for (int i = 0; i < 10; i++) {', expectedPosition: 0 },
      { id: 'block-print-i', label: "print('Iteração: \$i');", expectedPosition: 1 },
      { id: 'block-close-brace-4', label: '}', expectedPosition: 2 },
    ],
  },
  {
    id: 'block-assembly-try-catch',
    title: 'Tratamento de Exceções',
    description: 'Monte a estrutura correta de try-catch em Dart.',
    difficulty: 'hard',
    xpReward: 70,
    maxAttempts: 3,
    blocks: [
      { id: 'block-try', label: 'try {', expectedPosition: 0 },
      { id: 'block-risky-code', label: 'int resultado = 10 ~/ 0;', expectedPosition: 1 },
      { id: 'block-catch', label: '} catch (e) {', expectedPosition: 2 },
      { id: 'block-print-error', label: "print('Erro: \$e');", expectedPosition: 3 },
      { id: 'block-close-brace-5', label: '}', expectedPosition: 4 },
    ],
  },
];

// Função refatorada para receber a instância do Firestore (db)
async function seedBlockAssemblyChallenges(db) {
  console.log('[seed] Iniciando seed de Block Assembly Challenges...');

  for (const challenge of blockAssemblyChallenges) {
    try {
      await db.collection('challenges').doc(challenge.id).set(challenge, {
        merge: true,
      });
      console.log(`[seed] Criado desafio: ${challenge.title}`);
    } catch (error) {
      console.error(`[seed] Erro ao criar ${challenge.id}:`, error);
    }
  }

  console.log('[seed] Block Assembly Challenges seedados com sucesso!');
}

module.exports = {
  seedBlockAssemblyChallenges,
  blockAssemblyChallenges,
};
