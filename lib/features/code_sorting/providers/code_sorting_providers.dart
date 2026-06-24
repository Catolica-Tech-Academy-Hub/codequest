import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/actions/submit_sorting_attempt_use_case.dart';
import '../application/actions/validate_sorting_use_case.dart';
import '../data/repositories/code_sorting_repository.dart';
import '../domain/entities/code_sorting_challenge.dart';
import '../domain/entities/user_sorting_progress.dart';
import '../domain/repositories/code_sorting_repository_contract.dart';

final _firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final codeSortingRepositoryProvider =
    Provider<CodeSortingRepositoryContract>((ref) {
  return CodeSortingRepository(firestore: ref.watch(_firestoreProvider));
});

final validateSortingUseCaseProvider = Provider<ValidateSortingUseCase>(
  (ref) => const ValidateSortingUseCase(),
);

final submitSortingAttemptUseCaseProvider =
    Provider<SubmitSortingAttemptUseCase>((ref) {
  return SubmitSortingAttemptUseCase(
    repository: ref.watch(codeSortingRepositoryProvider),
    validateSorting: ref.watch(validateSortingUseCaseProvider),
  );
});

final codeSortingChallengeProvider =
    FutureProvider.family<CodeSortingChallenge, String>(
        (ref, challengeId) async {
  return ref.watch(codeSortingRepositoryProvider).getChallengeById(challengeId);
});

final userSortingProgressProvider =
    FutureProvider.family<UserSortingProgress?,
        ({String userId, String challengeId})>((ref, params) async {
  return ref.watch(codeSortingRepositoryProvider).getUserProgress(
        userId: params.userId,
        challengeId: params.challengeId,
      );
});
