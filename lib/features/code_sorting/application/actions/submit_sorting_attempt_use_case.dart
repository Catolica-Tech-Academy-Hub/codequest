import 'package:uuid/uuid.dart';

import 'package:codequest/features/code_sorting/domain/entities/code_sorting_challenge.dart';
import 'package:codequest/features/code_sorting/domain/entities/sorting_attempt.dart';
import 'package:codequest/features/code_sorting/domain/entities/user_sorting_progress.dart';
import 'package:codequest/features/code_sorting/domain/repositories/code_sorting_repository_contract.dart';
import 'package:codequest/features/code_sorting/domain/value_objects/line_id.dart';
import 'package:codequest/features/code_sorting/application/actions/validate_sorting_use_case.dart';

/// Orquestra a submissão de uma tentativa de ordenação.
///
/// Camada: application — coordena validação, persistência e progresso.
class SubmitSortingAttemptUseCase {
  SubmitSortingAttemptUseCase({
    required CodeSortingRepositoryContract repository,
    required ValidateSortingUseCase validateSorting,
  })  : _repository = repository,
        _validateSorting = validateSorting;

  final CodeSortingRepositoryContract _repository;
  final ValidateSortingUseCase _validateSorting;
  static const _uuid = Uuid();

  Future<SortingValidationResult> call({
    required CodeSortingChallenge challenge,
    required String userId,
    required List<LineId> submittedOrder,
  }) async {
    final existingProgress = await _repository.getUserProgress(
      userId: userId,
      challengeId: challenge.id,
    );

    final attemptNumber = (existingProgress?.attemptCount ?? 0) + 1;

    final result = _validateSorting.call(
      challenge: challenge,
      submittedOrder: submittedOrder,
      attemptNumber: attemptNumber,
    );

    final attempt = SortingAttempt(
      id: _uuid.v4(),
      challengeId: challenge.id,
      userId: userId,
      submittedOrder: submittedOrder,
      isCorrect: result.isCorrect,
      attemptNumber: attemptNumber,
      createdAt: DateTime.now(),
      xpEarned: result.xpEarned,
      feedback: result.feedback,
    );

    await _repository.saveAttempt(attempt);

    final updatedProgress = UserSortingProgress(
      userId: userId,
      challengeId: challenge.id,
      isCompleted: result.isCorrect,
      attemptCount: attemptNumber,
      totalXpEarned: (existingProgress?.totalXpEarned ?? 0) + result.xpEarned,
      lastAttemptAt: DateTime.now(),
      firstCompletedAt: result.isCorrect
          ? (existingProgress?.firstCompletedAt ?? DateTime.now())
          : existingProgress?.firstCompletedAt,
    );

    await _repository.updateUserProgress(updatedProgress);

    return result;
  }
}
