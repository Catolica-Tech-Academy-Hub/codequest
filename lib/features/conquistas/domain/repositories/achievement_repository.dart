import '../entities/user_achievement.dart';
import '../entities/xp_history_entry.dart';

/// Contrato que define as operações disponíveis para o módulo de conquistas.
///
/// Implementado na camada [data]; nunca importa Firebase ou Flutter aqui.
abstract interface class AchievementRepository {
  // ── Conquistas ──────────────────────────────────────────────────────────────

  /// Retorna todas as conquistas do [userId], desbloqueadas ou não.
  Future<List<UserAchievement>> getAchievements(String userId);

  /// Stream de conquistas para atualizações em tempo real.
  Stream<List<UserAchievement>> watchAchievements(String userId);

  /// Atualiza o progresso de uma conquista. Caso o progresso atinja o alvo,
  /// a conquista é automaticamente marcada como desbloqueada.
  Future<void> updateAchievementProgress({
    required String userId,
    required String achievementId,
    required int progress,
  });

  // ── Histórico de XP ─────────────────────────────────────────────────────────

  /// Registra um novo ganho de XP no histórico do [userId].
  Future<void> addXpEntry(XpHistoryEntry entry);

  /// Retorna o histórico de XP do [userId], ordenado do mais recente para o mais antigo.
  Future<List<XpHistoryEntry>> getXpHistory(String userId);

  /// Stream do histórico de XP para atualizações em tempo real.
  Stream<List<XpHistoryEntry>> watchXpHistory(String userId);

  /// Retorna o total de XP acumulado pelo [userId].
  Future<int> getTotalXp(String userId);
}
