import 'package:equatable/equatable.dart';

/// Entidade que rastreia o progresso de um usuário em um desafio específico.
///
/// Camada: domain — sem dependências externas.
///
/// Armazena histórico de tentativas, estado de conclusão e recompensas.
class UserChallengeProgress extends Equatable {
  const UserChallengeProgress({
    required this.userId,
    required this.challengeId,
    required this.isCompleted,
    required this.attemptCount,
    required this.totalXpEarned,
    this.lastAttemptAt,
    this.firstCompletedAt,
  });

  /// ID do usuário.
  final String userId;

  /// ID do desafio.
  final String challengeId;

  /// Se o usuário já completou este desafio corretamente.
  final bool isCompleted;

  /// Quantas tentativas foram feitas.
  final int attemptCount;

  /// Total de XP ganho neste desafio (inclui tentativas parciais se configurado).
  final int totalXpEarned;

  /// Timestamp da última tentativa, se houver.
  final DateTime? lastAttemptAt;

  /// Timestamp da primeira conclusão correta, se houver.
  final DateTime? firstCompletedAt;

  @override
  List<Object?> get props => [
    userId,
    challengeId,
    isCompleted,
    attemptCount,
    totalXpEarned,
    lastAttemptAt,
    firstCompletedAt,
  ];

  @override
  String toString() =>
      'UserChallengeProgress(user: $userId, challenge: $challengeId, completed: $isCompleted)';
}
