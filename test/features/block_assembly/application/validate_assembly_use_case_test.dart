import 'package:flutter_test/flutter_test.dart';

import 'package:codequest/features/block_assembly/application/actions/validate_assembly_use_case.dart';
import 'package:codequest/features/block_assembly/domain/entities/assembly_challenge.dart';
import 'package:codequest/features/block_assembly/domain/entities/logic_block.dart';
import 'package:codequest/features/block_assembly/domain/errors/block_assembly_error.dart';
import 'package:codequest/features/block_assembly/domain/value_objects/block_id.dart';
import 'package:codequest/features/block_assembly/domain/value_objects/block_label.dart';

import '../mocks/mock_block_assembly_repository.dart';

void main() {
  group('ValidateAssemblyUseCase', () {
    late ValidateAssemblyUseCase useCase;
    late MockBlockAssemblyRepository mockRepository;

    setUp(() {
      mockRepository = MockBlockAssemblyRepository();
      useCase = ValidateAssemblyUseCase(mockRepository);
    });

    group('validação de sequência correta', () {
      test('deve retornar isCorrect: true para sequência correta', () async {
        // Arrange
        final challenge = AssemblyChallenge(
          id: 'test-challenge',
          title: 'Test',
          description: 'Test challenge',
          blocks: [
            LogicBlock(
              id: const BlockId('block-1'),
              label: const BlockLabel('Block 1'),
              expectedPosition: 0,
            ),
            LogicBlock(
              id: const BlockId('block-2'),
              label: const BlockLabel('Block 2'),
              expectedPosition: 1,
            ),
          ],
          xpReward: 50,
          maxAttempts: 3,
        );

        final userSequence = [
          const BlockId('block-1'),
          const BlockId('block-2'),
        ];

        // Act
        final result = await useCase.call(
          challenge: challenge,
          userSequence: userSequence,
          attemptNumber: 1,
        );

        // Assert
        expect(result.isCorrect, true);
        expect(result.feedback, contains('Parabéns'));
        expect(result.xpEarned, equals(50 + 10)); // Bônus na primeira tentativa
      });

      test('deve retornar isCorrect: false para sequência incorreta', () async {
        // Arrange
        final challenge = AssemblyChallenge(
          id: 'test-challenge',
          title: 'Test',
          description: 'Test challenge',
          blocks: [
            LogicBlock(
              id: const BlockId('block-1'),
              label: const BlockLabel('Block 1'),
              expectedPosition: 0,
            ),
            LogicBlock(
              id: const BlockId('block-2'),
              label: const BlockLabel('Block 2'),
              expectedPosition: 1,
            ),
          ],
          xpReward: 50,
          maxAttempts: 3,
        );

        // Sequência invertida (incorreta)
        final userSequence = [
          const BlockId('block-2'),
          const BlockId('block-1'),
        ];

        // Act
        final result = await useCase.call(
          challenge: challenge,
          userSequence: userSequence,
          attemptNumber: 1,
        );

        // Assert
        expect(result.isCorrect, false);
        expect(result.xpEarned, equals(0));
        expect(result.feedback, contains('incorreto'));
      });

      test('deve ter feedback específico sobre posição incorreta', () async {
        // Arrange
        final challenge = AssemblyChallenge(
          id: 'test-challenge',
          title: 'Test',
          description: 'Test challenge',
          blocks: [
            LogicBlock(
              id: const BlockId('block-a'),
              label: const BlockLabel('void main'),
              expectedPosition: 0,
            ),
            LogicBlock(
              id: const BlockId('block-b'),
              label: const BlockLabel('print'),
              expectedPosition: 1,
            ),
          ],
          xpReward: 50,
          maxAttempts: 3,
        );

        final userSequence = [
          const BlockId('block-b'), // Errado na posição 1
          const BlockId('block-a'),
        ];

        // Act
        final result = await useCase.call(
          challenge: challenge,
          userSequence: userSequence,
          attemptNumber: 1,
        );

        // Assert
        expect(result.isCorrect, false);
        expect(result.feedback, contains('posição 1'));
        expect(result.feedback, contains('print'));
        expect(result.feedback, contains('void main'));
      });
    });

    group('casos extremos', () {
      test('deve rejeitar sequência vazia', () async {
        // Arrange
        final challenge = AssemblyChallenge(
          id: 'test-challenge',
          title: 'Test',
          description: 'Test challenge',
          blocks: [
            LogicBlock(
              id: const BlockId('block-1'),
              label: const BlockLabel('Block 1'),
              expectedPosition: 0,
            ),
          ],
          xpReward: 50,
          maxAttempts: 3,
        );

        final userSequence = <BlockId>[];

        // Act
        final result = await useCase.call(
          challenge: challenge,
          userSequence: userSequence,
          attemptNumber: 1,
        );

        // Assert
        expect(result.isCorrect, false);
        expect(result.feedback, contains('não selecionou'));
      });

      test('deve rejeitar sequência incompleta', () async {
        // Arrange
        final challenge = AssemblyChallenge(
          id: 'test-challenge',
          title: 'Test',
          description: 'Test challenge',
          blocks: [
            LogicBlock(
              id: const BlockId('block-1'),
              label: const BlockLabel('Block 1'),
              expectedPosition: 0,
            ),
            LogicBlock(
              id: const BlockId('block-2'),
              label: const BlockLabel('Block 2'),
              expectedPosition: 1,
            ),
          ],
          xpReward: 50,
          maxAttempts: 3,
        );

        final userSequence = [const BlockId('block-1')]; // Apenas 1 de 2

        // Act
        final result = await useCase.call(
          challenge: challenge,
          userSequence: userSequence,
          attemptNumber: 1,
        );

        // Assert
        expect(result.isCorrect, false);
        expect(result.feedback, contains('incompleta'));
        expect(result.feedback, contains('2'));
      });
    });

    group('cálculo de XP', () {
      test('deve dar bônus na primeira tentativa', () async {
        // Arrange
        final challenge = AssemblyChallenge(
          id: 'test-challenge',
          title: 'Test',
          description: 'Test challenge',
          blocks: [
            LogicBlock(
              id: const BlockId('block-1'),
              label: const BlockLabel('Block 1'),
              expectedPosition: 0,
            ),
          ],
          xpReward: 100, // Para cálculo fácil do bônus
          maxAttempts: 3,
        );

        final userSequence = [const BlockId('block-1')];

        // Act
        final result1 = await useCase.call(
          challenge: challenge,
          userSequence: userSequence,
          attemptNumber: 1,
        );

        // Assert
        expect(result1.xpEarned, equals(100 + 20)); // 100 + (100 / 5)
      });

      test('deve dar XP normal em tentativas posteriores', () async {
        // Arrange
        final challenge = AssemblyChallenge(
          id: 'test-challenge',
          title: 'Test',
          description: 'Test challenge',
          blocks: [
            LogicBlock(
              id: const BlockId('block-1'),
              label: const BlockLabel('Block 1'),
              expectedPosition: 0,
            ),
          ],
          xpReward: 100,
          maxAttempts: 5,
        );

        final userSequence = [const BlockId('block-1')];

        // Act
        final result2 = await useCase.call(
          challenge: challenge,
          userSequence: userSequence,
          attemptNumber: 2,
        );

        // Assert (sem bônus)
        expect(result2.xpEarned, equals(100));
      });
    });
  });
}
