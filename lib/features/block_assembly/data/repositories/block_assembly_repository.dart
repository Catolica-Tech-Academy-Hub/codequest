import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'package:codequest/features/block_assembly/domain/entities/assembly_attempt.dart';
import 'package:codequest/features/block_assembly/domain/entities/assembly_challenge.dart';
import 'package:codequest/features/block_assembly/domain/entities/user_challenge_progress.dart';
import 'package:codequest/features/block_assembly/domain/errors/block_assembly_error.dart';
import 'package:codequest/features/block_assembly/domain/repositories/block_assembly_repository_contract.dart';
import 'package:codequest/features/block_assembly/data/dtos/assembly_attempt_dto.dart';
import 'package:codequest/features/block_assembly/data/dtos/assembly_challenge_dto.dart';
import 'package:codequest/features/block_assembly/data/dtos/user_challenge_progress_dto.dart';

/// Implementação concreta do [BlockAssemblyRepositoryContract] usando Cloud Firestore.
///
/// Camada: data — único lugar que importa firebase_core/cloud_firestore.
///
/// Estrutura Firestore:
/// - `challenges/{challengeId}` → documento do desafio
/// - `blockAssemblyAttempts/{attemptId}` → registro de tentativas globais
/// - `users/{userId}/challengeProgress/{challengeId}` → progresso por usuário
class BlockAssemblyRepository implements BlockAssemblyRepositoryContract {
  BlockAssemblyRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;
  static const _uuid = Uuid();

  // =========================================================================
  // Desafios
  // =========================================================================

  @override
  Future<AssemblyChallenge> getChallengeById(String challengeId) async {
    try {
      final doc = await _firestore
          .collection('challenges')
          .doc(challengeId)
          .get();

      if (!doc.exists) {
        throw ChallengeNotAccessibleError(
          'Desafio "$challengeId" não encontrado.',
        );
      }

      final dto = AssemblyChallengeDto.fromFirestore(
        doc.data() ?? {},
      );
      return dto.toDomain();
    } catch (e) {
      if (e is BlockAssemblyError) rethrow;
      throw RepositoryError('Erro ao recuperar desafio: $e');
    }
  }

  @override
  Future<List<AssemblyChallenge>> getAllChallenges() async {
    try {
      final query = await _firestore
          .collection('challenges')
          .get();

      return query.docs
          .map((doc) => AssemblyChallengeDto.fromFirestore(
                doc.data(),
              ).toDomain(),)
          .toList();
    } catch (e) {
      throw RepositoryError('Erro ao recuperar desafios: $e');
    }
  }

  // =========================================================================
  // Tentativas
  // =========================================================================

  @override
  Future<void> saveAttempt(AssemblyAttempt attempt) async {
    try {
      final dto = AssemblyAttemptDto(
        id: attempt.id,
        challengeId: attempt.challengeId,
        userId: attempt.userId,
        selectedBlockSequence:
            attempt.selectedBlockSequence.map((b) => b.value).toList(),
        isCorrect: attempt.isCorrect,
        attemptNumber: attempt.attemptNumber,
        createdAt: attempt.createdAt,
        xpEarned: attempt.xpEarned,
        feedback: attempt.feedback,
      );

      await _firestore
          .collection('blockAssemblyAttempts')
          .doc(attempt.id)
          .set(dto.toFirestore());
    } catch (e) {
      throw RepositoryError('Erro ao salvar tentativa: $e');
    }
  }

  @override
  Future<List<AssemblyAttempt>> getAttemptHistory({
    required String userId,
    required String challengeId,
  }) async {
    try {
      final query = await _firestore
          .collection('blockAssemblyAttempts')
          .where('userId', isEqualTo: userId)
          .where('challengeId', isEqualTo: challengeId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => AssemblyAttemptDto.fromFirestore(
                doc.data(),
              ).toDomain(),)
          .toList();
    } catch (e) {
      throw RepositoryError(
        'Erro ao recuperar histórico de tentativas: $e',
      );
    }
  }

  // =========================================================================
  // Progresso do Usuário
  // =========================================================================

  @override
  Future<UserChallengeProgress?> getUserChallengeProgress({
    required String userId,
    required String challengeId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('challengeProgress')
          .doc(challengeId)
          .get();

      if (!doc.exists) return null;

      return UserChallengeProgressDto.fromFirestore(
        doc.data() ?? {},
      ).toDomain();
    } catch (e) {
      throw RepositoryError('Erro ao recuperar progresso: $e');
    }
  }

  @override
  Future<void> updateUserProgress(UserChallengeProgress progress) async {
    try {
      final dto = UserChallengeProgressDto(
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
          .collection('challengeProgress')
          .doc(progress.challengeId)
          .set(dto.toFirestore(), SetOptions(merge: true));

      // Atualiza XP total do usuário na coleção principal
      await _firestore
          .collection('users')
          .doc(progress.userId)
          .update({
        'totalXpEarned': FieldValue.increment(progress.totalXpEarned),
      }).catchError((_) {
        // Usuário pode não existir em 'users' ainda, ignora
      });
    } catch (e) {
      throw RepositoryError('Erro ao atualizar progresso: $e');
    }
  }

  @override
  Stream<UserChallengeProgress> watchUserProgress({
    required String userId,
    required String challengeId,
  }) {
    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('challengeProgress')
          .doc(challengeId)
          .snapshots()
          .map((doc) {
        if (!doc.exists) {
          throw ChallengeNotAccessibleError(
            'Progresso do desafio não encontrado.',
          );
        }
        return UserChallengeProgressDto.fromFirestore(
          doc.data() ?? {},
        ).toDomain();
      });
    } catch (e) {
      return Stream.error(
        RepositoryError('Erro ao observar progresso: $e'),
      );
    }
  }
}
