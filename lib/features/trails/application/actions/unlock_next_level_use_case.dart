import 'package:codequest/features/trails/domain/entities/user_trail_progress.dart';
import 'package:codequest/features/trails/domain/repositories/trail_repository_contract.dart';

class UnlockNextLevelUseCase {
  const UnlockNextLevelUseCase(this._repository);

  final TrailRepositoryContract _repository;

  Future<void> execute({
    required String userId,
    required String trailId,
    required int completedLevelIndex,
  }) async {
    final currentProgress = await _repository.getUserProgress(
      userId: userId,
      trailId: trailId,
    );

    final nextLevelIndex = completedLevelIndex + 1;

    if (currentProgress == null) {
      await _repository.updateUserProgress(
        UserTrailProgress(
          userId: userId,
          trailId: trailId,
          highestUnlockedLevelIndex: nextLevelIndex,
        ),
      );
      return;
    }

    if (nextLevelIndex > currentProgress.highestUnlockedLevelIndex) {
      await _repository.updateUserProgress(
        currentProgress.copyWith(highestUnlockedLevelIndex: nextLevelIndex),
      );
    }
  }
}
