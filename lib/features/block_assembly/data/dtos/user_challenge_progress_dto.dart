import 'package:codequest/features/block_assembly/domain/entities/user_challenge_progress.dart';

/// DTO que mapeia o progresso do usuário do Firestore para entidade de domínio.
///
/// Camada: data — serialização e mapeamento de dados externos.
///
/// Campos esperados no Firestore:
///   userId              : String
///   challengeId         : String
///   isCompleted         : bool
///   attemptCount        : int
///   totalXpEarned       : int
///   lastAttemptAt       : Timestamp (opcional)
///   firstCompletedAt    : Timestamp (opcional)
class UserChallengeProgressDto {
  const UserChallengeProgressDto({
    required this.userId,
    required this.challengeId,
    required this.isCompleted,
    required this.attemptCount,
    required this.totalXpEarned,
    this.lastAttemptAt,
    this.firstCompletedAt,
  });

  final String userId;
  final String challengeId;
  final bool isCompleted;
  final int attemptCount;
  final int totalXpEarned;
  final DateTime? lastAttemptAt;
  final DateTime? firstCompletedAt;

  /// Converte DTO para entidade de domínio.
  UserChallengeProgress toDomain() {
    return UserChallengeProgress(
      userId: userId,
      challengeId: challengeId,
      isCompleted: isCompleted,
      attemptCount: attemptCount,
      totalXpEarned: totalXpEarned,
      lastAttemptAt: lastAttemptAt,
      firstCompletedAt: firstCompletedAt,
    );
  }

  /// Cria DTO a partir de Map (Firestore doc).
  factory UserChallengeProgressDto.fromFirestore(Map<String, dynamic> data) {
    return UserChallengeProgressDto(
      userId: (data['userId'] as String?) ?? '',
      challengeId: (data['challengeId'] as String?) ?? '',
      isCompleted: (data['isCompleted'] as bool?) ?? false,
      attemptCount: (data['attemptCount'] as int?) ?? 0,
      totalXpEarned: (data['totalXpEarned'] as int?) ?? 0,
      lastAttemptAt: (data['lastAttemptAt'] as DateTime?),
      firstCompletedAt: (data['firstCompletedAt'] as DateTime?),
    );
  }

  /// Converte DTO para Map para salvar no Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'challengeId': challengeId,
      'isCompleted': isCompleted,
      'attemptCount': attemptCount,
      'totalXpEarned': totalXpEarned,
      'lastAttemptAt': lastAttemptAt,
      'firstCompletedAt': firstCompletedAt,
    };
  }
}
