import '../entities/xp_history_entry.dart';
import '../repositories/achievement_repository.dart';

/// Caso de uso: atualiza conquistas relacionadas a streaks diários.
///
/// Deve ser chamado sempre que o streak do usuário for atualizado,
/// normalmente pelo módulo de Ranking.
class UpdateStreakProgressUseCase {
  final AchievementRepository _repository;

  const UpdateStreakProgressUseCase(this._repository);

  Future<List<String>> call({
    required String userId,
    required int currentStreakDays,
  }) async {
    final achievements = await _repository.getAchievements(userId);
    final unlocked = <String>[];

    for (final ua in achievements) {
      if (ua.isUnlocked) continue;
      if (ua.achievement.type != AchievementType.streak) continue;

      await _repository.updateAchievementProgress(
        userId: userId,
        achievementId: ua.achievement.id,
        progress: currentStreakDays,
      );

      if (currentStreakDays >= ua.targetProgress) {
        unlocked.add(ua.achievement.id);

        // Concede XP bônus pela conquista de streak.
        // O entry de XP é adicionado diretamente para evitar recursão.
        final bonusEntry = XpHistoryEntry(
          id: '${userId}_streak_${ua.achievement.id}_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          xpAmount: ua.achievement.xpReward,
          source: XpSource.achievementUnlocked,
          sourceId: ua.achievement.id,
          earnedAt: DateTime.now(),
        );
        await _repository.addXpEntry(bonusEntry);
      }
    }

    return unlocked;
  }
}
