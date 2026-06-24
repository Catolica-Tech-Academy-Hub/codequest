// Exemplo de integração da rota Block Assembly no GoRouter
// 
// Adicione este trecho ao seu lib/core/router.dart

import 'package:go_router/go_router.dart';

// Importar a página:
// import 'package:codequest/features/block_assembly/presentation/block_assembly_page.dart';

// Dentro do GoRouter, adicione a rota:
/*

GoRoute(
  path: '/challenge/block-assembly/:challengeId',
  name: 'blockAssemblyChallenge',
  builder: (context, state) {
    final challengeId = state.pathParameters['challengeId']!;
    final userId = state.extra as String?;
    
    // Obter userId do auth se não fornecido como extra
    final actualUserId = userId ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    
    return BlockAssemblyPage(
      challengeId: challengeId,
      userId: actualUserId,
    );
  },
),

*/

// Para navegar:
/*

// Option 1: Via context.push (recomendado com GoRouter)
context.push('/challenge/block-assembly/$challengeId', extra: userId);

// Option 2: Via context.go (substitui rota anterior)
context.go('/challenge/block-assembly/$challengeId', extra: userId);

// Option 3: Via GoRouter.of(context).pushNamed (nome nomeado)
GoRouter.of(context).pushNamed(
  'blockAssemblyChallenge',
  pathParameters: {'challengeId': challengeId},
  extra: userId,
);

*/
