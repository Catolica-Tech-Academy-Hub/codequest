import 'package:flutter_test/flutter_test.dart';

import 'package:codequest/features/block_assembly/application/actions/submit_assembly_attempt_use_case.dart';
import 'package:codequest/features/block_assembly/application/actions/validate_assembly_use_case.dart';
import 'package:codequest/features/block_assembly/domain/errors/block_assembly_error.dart';
import 'package:codequest/features/block_assembly/domain/value_objects/block_id.dart';

import '../mocks/mock_block_assembly_repository.dart';
import '../mocks/test_challenge_factory.dart';

void main() {
  group('SubmitAssemblyAttemptUseCase', () {
    late MockBlockAssemblyRepository mockRepository;
    late ValidateAssemblyUseCase validateUseCase;
    late SubmitAssemblyAttemptUseCase submitUseCase;

    setUp(() {
      mockRepository = MockBlockAssemblyRepository();
      validateUseCase = ValidateAssemblyUseCase(mockRepository);
      submitUseCase = SubmitAssemblyAttemptUseCase(
        repository: mockRepository,
        validateAssembly: validateUseCase,
      );
    });

    tearDown(() {
      mockRepository.reset();
    });

    group('tentativa bem-sucedida', () {
      test('deve salvar tentativa correta e atualizar XP', () async {
        // Arrange
        const userId = 'user-123';
        final challenge = TestChallengeFactory.createSimpleChallenge(
          id: 'challenge-1',
          blockCount: 3,
          xpReward: 50,
          maxAttempts: 3,
        );
        mockRepository.addChallenge(challenge);

        final correctSequence = [
          const BlockId('block-0'),
          const BlockId('block-1'),
          const BlockId('block-2'),
        ];

        // Act
        final result = await submitUseCase.call(
          challenge: challenge,
          userId: userId,
          selectedSequence: correctSequence,
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.isAlreadyCompleted, false);
        expect(result.xpEarned, equals(50 + 10)); // Bônus primeira tentativa
        expect(result.attempt, isNotNull);
        expect(result.attempt!.isCorrect, true);

        // Verificar progresso atualizado
        final progress = await mockRepository.getUserChallengeProgress(
          userId: userId,
          challengeId: challenge.id,
        );
        expect(progress?.isCompleted, true);
        expect(progress?.attemptCount, 1);
        expect(progress?.totalXpEarned, 60);
      });

      test('deve registrar tentativa incorreta sem XP', () async {
        // Arrange
        const userId = 'user-456';
        final challenge = TestChallengeFactory.createSimpleChallenge(
          id: 'challenge-2',
          blockCount: 3,
          xpReward: 50,
          maxAttempts: 3,
        );
        mockRepository.addChallenge(challenge);

        // Sequência invertida (incorreta)
        final wrongSequence = [
          const BlockId('block-2'),
          const BlockId('block-1'),
          const BlockId('block-0'),
        ];

        // Act
        final result = await submitUseCase.call(
          challenge: challenge,
          userId: userId,
          selectedSequence: wrongSequence,
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.xpEarned, 0);
        expect(result.attempt!.isCorrect, false);

        // Verificar progresso não completado
        final progress = await mockRepository.getUserChallengeProgress(
          userId: userId,
          challengeId: challenge.id,
        );
        expect(progress?.isCompleted, false);
        expect(progress?.attemptCount, 1);
        expect(progress?.totalXpEarned, 0);
      });
    });

    group('múltiplas tentativas', () {
      test('deve incrementar contador de tentativas', () async {
        // Arrange
        const userId = 'user-789';
        final challenge = TestChallengeFactory.createSimpleChallenge(
          id: 'challenge-3',
          blockCount: 2,
          xpReward: 40,
          maxAttempts: 3,
        );
        mockRepository.addChallenge(challenge);

        final wrongSequence = [
          const BlockId('block-1'),
          const BlockId('block-0'),
        ];

        final correctSequence = [
          const BlockId('block-0'),
          const BlockId('block-1'),
        ];

        // Act - Primeira tentativa (incorreta)
        await submitUseCase.call(
          challenge: challenge,
          userId: userId,
          selectedSequence: wrongSequence,
        );

        // Verificar 1ª tentativa
        var progress = await mockRepository.getUserChallengeProgress(
          userId: userId,
          challengeId: challenge.id,
        );
        expect(progress?.attemptCount, 1);
        expect(progress?.isCompleted, false);

        // Act - Segunda tentativa (correta)
        final result = await submitUseCase.call(
          challenge: challenge,
          userId: userId,
          selectedSequence: correctSequence,
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.xpEarned, 40); // SEM bônus (não é primeira tentativa)

        progress = await mockRepository.getUserChallengeProgress(
          userId: userId,
          challengeId: challenge.id,
        );
        expect(progress?.attemptCount, 2);
        expect(progress?.isCompleted, true);
        expect(progress?.totalXpEarned, 40);
      });

      test('deve lançar erro ao exceder tentativas', () async {
        // Arrange
        const userId = 'user-999';
        final challenge = TestChallengeFactory.createSimpleChallenge(
          id: 'challenge-4',
          blockCount: 2,
          xpReward: 30,
          maxAttempts: 2, // Limite baixo para teste
        );
        mockRepository.addChallenge(challenge);

        // Progresso com 2 tentativas já feitas
        mockRepository.addProgress(
          TestChallengeFactory.createProgress(
            userId: userId,
            challengeId: challenge.id,
            attemptCount: 2,
            totalXpEarned: 0,
          ),
        );

        final sequence = [
          const BlockId('block-0'),
          const BlockId('block-1'),
        ];

        // Act & Assert
        expect(
          () => submitUseCase.call(
            challenge: challenge,
            userId: userId,
            selectedSequence: sequence,
          ),
          throwsA(isA<MaxAttemptsExceededError>()),
        );
      });
    });

    group('desafio já completado', () {
      test('deve retornar resultado de já completado', () async {
        // Arrange
        const userId = 'user-completed';
        final challenge = TestChallengeFactory.createSimpleChallenge(
          id: 'challenge-5',
          blockCount: 2,
          xpReward: 50,
        );
        mockRepository.addChallenge(challenge);

        // Progresso já completado
        mockRepository.addProgress(
          TestChallengeFactory.createProgress(
            userId: userId,
            challengeId: challenge.id,
            isCompleted: true,
            attemptCount: 1,
            totalXpEarned: 50,
          ),
        );

        final sequence = [
          const BlockId('block-0'),
          const BlockId('block-1'),
        ];

        // Act
        final result = await submitUseCase.call(
          challenge: challenge,
          userId: userId,
          selectedSequence: sequence,
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.isAlreadyCompleted, true);
        expect(result.xpEarned, 0);
      });
    });

    group('histórico de tentativas', () {
      test('deve salvar histórico de tentativas', () async {
        // Arrange
        const userId = 'user-history';
        final challenge = TestChallengeFactory.createSimpleChallenge(
          id: 'challenge-6',
          blockCount: 2,
        );
        mockRepository.addChallenge(challenge);

        final sequence = [
          const BlockId('block-0'),
          const BlockId('block-1'),
        ];

        // Act
        await submitUseCase.call(
          challenge: challenge,
          userId: userId,
          selectedSequence: sequence,
        );

        // Assert
        final attempts = await mockRepository.getAttemptHistory(
          userId: userId,
          challengeId: challenge.id,
        );
        expect(attempts, isNotEmpty);
        expect(attempts.length, 1);
        expect(attempts[0].userId, userId);
        expect(attempts[0].attemptNumber, 1);
      });
    });
  });
}
