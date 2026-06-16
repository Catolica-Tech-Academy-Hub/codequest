import 'package:codequest/features/block_assembly/domain/entities/assembly_challenge.dart';
import 'package:codequest/features/block_assembly/domain/entities/logic_block.dart';
import 'package:codequest/features/block_assembly/domain/entities/user_challenge_progress.dart';
import 'package:codequest/features/block_assembly/domain/value_objects/block_id.dart';
import 'package:codequest/features/block_assembly/domain/value_objects/block_label.dart';

/// Factory para criar desafios de teste
class TestChallengeFactory {
  static AssemblyChallenge createSimpleChallenge({
    String id = 'test-challenge-1',
    int blockCount = 3,
    int xpReward = 50,
    int maxAttempts = 3,
    String difficulty = 'easy',
  }) {
    final blocks = List.generate(
      blockCount,
      (index) => LogicBlock(
        id: BlockId('block-$index'),
        label: BlockLabel('Bloco $index'),
        expectedPosition: index,
      ),
    );

    return AssemblyChallenge(
      id: id,
      title: 'Test Challenge $id',
      description: 'Desafio de teste',
      blocks: blocks,
      xpReward: xpReward,
      maxAttempts: maxAttempts,
      difficulty: difficulty,
    );
  }

  static UserChallengeProgress createProgress({
    required String userId,
    required String challengeId,
    bool isCompleted = false,
    int attemptCount = 0,
    int totalXpEarned = 0,
  }) {
    return UserChallengeProgress(
      userId: userId,
      challengeId: challengeId,
      isCompleted: isCompleted,
      attemptCount: attemptCount,
      totalXpEarned: totalXpEarned,
      lastAttemptAt: attemptCount > 0 ? DateTime.now() : null,
      firstCompletedAt: isCompleted ? DateTime.now() : null,
    );
  }
}
