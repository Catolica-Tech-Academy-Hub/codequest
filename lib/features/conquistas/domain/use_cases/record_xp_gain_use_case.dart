import '../entities/xp_history_entry.dart';
import '../repositories/achievement_repository.dart';

/// Resultado da operação de registro de XP.
class RecordXpResult {
  final int totalXp;
  final List<String> unlockedAchievementIds;

  const RecordXpResult({
    required this.totalXp,
    required this.unlockedAchievementIds,
  });
}

/// Caso de uso: registra um ganho de XP e atualiza conquistas relacionadas.
///
/// Este use case é o ponto central de evolução do usuário. Toda ação que
/// concede XP deve passar por aqui, garantindo que o histórico seja mantido
/// e as conquistas sejam verificadas.
class RecordXpGainUseCase {
  final AchievementRepository _repository;

  const RecordXpGainUseCase(this._repository);

  Future<RecordXpResult> call({
    required String userId,
    required int xpAmount,
    required XpSource source,
    required String sourceId,
  }) async {
    // 1. Registra a entrada no histórico de XP.
    final entry = XpHistoryEntry(
      id: '${userId}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      xpAmount: xpAmount,
      source: source,
      sourceId: sourceId,
      earnedAt: DateTime.now(),
    );
    await _repository.addXpEntry(entry);

    // 2. Calcula o XP total atualizado.
    final totalXp = await _repository.getTotalXp(userId);

    // 3. Verifica se conquistas de XP devem ser desbloqueadas.
    final unlockedIds = await _checkXpMilestones(userId, totalXp);

    return RecordXpResult(
      totalXp: totalXp,
      unlockedAchievementIds: unlockedIds,
    );
  }

  Future<List<String>> _checkXpMilestones(String userId, int totalXp) async {
    final achievements = await _repository.getAchievements(userId);
    final unlocked = <String>[];

    for (final ua in achievements) {
      if (ua.isUnlocked) continue;
      if (ua.achievement.type != AchievementType.xpMilestone) continue;

      await _repository.updateAchievementProgress(
        userId: userId,
        achievementId: ua.achievement.id,
        progress: totalXp,
      );

      if (totalXp >= ua.targetProgress) {
        unlocked.add(ua.achievement.id);
      }
    }

    return unlocked;
  }
}

// Reexporta para evitar imports extras nos use cases que dependem de XpSource.
export '../entities/xp_history_entry.dart' show XpSource, AchievementType;
