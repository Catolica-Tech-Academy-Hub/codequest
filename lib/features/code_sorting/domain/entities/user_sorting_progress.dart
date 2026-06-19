import 'package:equatable/equatable.dart';

/// Progresso do usuário em um desafio de ordenação.
///
/// Camada: domain — sem dependências externas.
class UserSortingProgress extends Equatable {
  const UserSortingProgress({
    required this.userId,
    required this.challengeId,
    required this.isCompleted,
    required this.attemptCount,
    required this.totalXpEarned,
    required this.lastAttemptAt,
    this.firstCompletedAt,
  });

  final String userId;
  final String challengeId;
  final bool isCompleted;
  final int attemptCount;
  final int totalXpEarned;
  final DateTime lastAttemptAt;
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
}
