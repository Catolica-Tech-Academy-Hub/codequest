import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/code_sorting_challenge.dart';
import '../../domain/entities/sorting_attempt.dart';
import '../../domain/entities/user_sorting_progress.dart';
import '../../domain/errors/code_sorting_error.dart';
import '../../domain/repositories/code_sorting_repository_contract.dart';
import '../dtos/code_sorting_challenge_dto.dart';
import '../dtos/sorting_attempt_dto.dart';
import '../dtos/user_sorting_progress_dto.dart';

/// Implementação Firestore do [CodeSortingRepositoryContract].
///
/// Camada: data — único lugar que importa cloud_firestore.
///
/// Coleções:
/// - `codeSortingChallenges/{challengeId}`
/// - `codeSortingAttempts/{attemptId}`
/// - `users/{userId}/sortingProgress/{challengeId}`
class CodeSortingRepository implements CodeSortingRepositoryContract {
  CodeSortingRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;
  static const _uuid = Uuid();

  @override
  Future<CodeSortingChallenge> getChallengeById(String challengeId) async {
    try {
      final doc = await _firestore
          .collection('codeSortingChallenges')
          .doc(challengeId)
          .get();

      if (!doc.exists) {
        throw ChallengeNotFoundError('Desafio "$challengeId" não encontrado.');
      }

      return CodeSortingChallengeDto.fromFirestore(
        {'id': doc.id, ...doc.data()!},
      ).toDomain();
    } catch (e) {
      if (e is CodeSortingError) rethrow;
      throw RepositoryError('Erro ao recuperar desafio: $e');
    }
  }

  @override
  Future<List<CodeSortingChallenge>> getAllChallenges() async {
    try {
      final query =
          await _firestore.collection('codeSortingChallenges').get();
      return query.docs
          .map((doc) => CodeSortingChallengeDto.fromFirestore(
                {'id': doc.id, ...doc.data()},
              ).toDomain())
          .toList();
    } catch (e) {
      throw RepositoryError('Erro ao listar desafios: $e');
    }
  }

  @override
  Future<void> saveAttempt(SortingAttempt attempt) async {
    try {
      final dto = SortingAttemptDto(
        id: attempt.id,
        challengeId: attempt.challengeId,
        userId: attempt.userId,
        submittedOrder: attempt.submittedOrder.map((l) => l.value).toList(),
        isCorrect: attempt.isCorrect,
        attemptNumber: attempt.attemptNumber,
        createdAt: attempt.createdAt,
        xpEarned: attempt.xpEarned,
        feedback: attempt.feedback,
      );
      await _firestore
          .collection('codeSortingAttempts')
          .doc(attempt.id)
          .set(dto.toFirestore());
    } catch (e) {
      throw RepositoryError('Erro ao salvar tentativa: $e');
    }
  }

  @override
  Future<List<SortingAttempt>> getAttemptHistory({
    required String userId,
    required String challengeId,
  }) async {
    try {
      final query = await _firestore
          .collection('codeSortingAttempts')
          .where('userId', isEqualTo: userId)
          .where('challengeId', isEqualTo: challengeId)
          .orderBy('createdAt', descending: true)
          .get();
      return query.docs
          .map((doc) =>
              SortingAttemptDto.fromFirestore(doc.data()).toDomain())
          .toList();
    } catch (e) {
      throw RepositoryError('Erro ao recuperar histórico: $e');
    }
  }

  @override
  Future<UserSortingProgress?> getUserProgress({
    required String userId,
    required String challengeId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('sortingProgress')
          .doc(challengeId)
          .get();
      if (!doc.exists) return null;
      return UserSortingProgressDto.fromFirestore(doc.data()!).toDomain();
    } catch (e) {
      throw RepositoryError('Erro ao recuperar progresso: $e');
    }
  }

  @override
  Future<void> updateUserProgress(UserSortingProgress progress) async {
    try {
      final dto = UserSortingProgressDto(
        userId: progress.userId,
        challengeId: progress.challengeId,
        isCompleted: progress.isCompleted,
        attemptCount: progress.attemptCount,
        totalXpEarned: progress.totalXpEarned,
        lastAttemptAt: progress.lastAttemptAt,
        firstCompletedAt: progress.firstCompletedAt,
      );
      await _firestore
          .collection('users')
          .doc(progress.userId)
          .collection('sortingProgress')
          .doc(progress.challengeId)
          .set(dto.toFirestore(), SetOptions(merge: true));

      if (progress.isCompleted) {
        await _firestore
            .collection('users')
            .doc(progress.userId)
            .update({'totalXpEarned': FieldValue.increment(progress.totalXpEarned)})
            .catchError((_) {});
      }
    } catch (e) {
      throw RepositoryError('Erro ao atualizar progresso: $e');
    }
  }

  @override
  Stream<UserSortingProgress> watchUserProgress({
    required String userId,
    required String challengeId,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('sortingProgress')
        .doc(challengeId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) throw ChallengeNotFoundError('Progresso não encontrado.');
      return UserSortingProgressDto.fromFirestore(doc.data()!).toDomain();
    });
  }
}
