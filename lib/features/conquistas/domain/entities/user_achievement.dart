import 'achievement.dart';

/// Representa o estado de uma conquista vinculada a um usuário.
///
/// Combina a definição da conquista com os dados de progresso do usuário.
class UserAchievement {
  final String userId;
  final Achievement achievement;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int currentProgress;
  final int targetProgress;

  const UserAchievement({
    required this.userId,
    required this.achievement,
    required this.isUnlocked,
    this.unlockedAt,
    required this.currentProgress,
    required this.targetProgress,
  });

  /// Percentual de progresso entre 0.0 e 1.0.
  double get progressPercent =>
      targetProgress == 0 ? 0 : (currentProgress / targetProgress).clamp(0.0, 1.0);

  UserAchievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? currentProgress,
  }) {
    return UserAchievement(
      userId: userId,
      achievement: achievement,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress,
    );
  }
}
