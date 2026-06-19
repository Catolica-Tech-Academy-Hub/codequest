import '../entities/code_sorting_challenge.dart';
import '../entities/sorting_attempt.dart';
import '../entities/user_sorting_progress.dart';

/// Contrato do repositório de ordenação de código.
///
/// Camada: domain — sem dependências externas.
abstract class CodeSortingRepositoryContract {
  Future<CodeSortingChallenge> getChallengeById(String challengeId);
  Future<List<CodeSortingChallenge>> getAllChallenges();

  Future<void> saveAttempt(SortingAttempt attempt);
  Future<List<SortingAttempt>> getAttemptHistory({
    required String userId,
    required String challengeId,
  });

  Future<UserSortingProgress?> getUserProgress({
    required String userId,
    required String challengeId,
  });

  Future<void> updateUserProgress(UserSortingProgress progress);

  Stream<UserSortingProgress> watchUserProgress({
    required String userId,
    required String challengeId,
  });
}
