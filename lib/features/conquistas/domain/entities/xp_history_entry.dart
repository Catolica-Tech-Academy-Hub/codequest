/// Representa um registro individual no histórico de XP do usuário.
///
/// Cada ação do usuário que concede XP gera uma entrada neste histórico.
class XpHistoryEntry {
  final String id;
  final String userId;
  final int xpAmount;
  final XpSource source;
  final String sourceId;
  final DateTime earnedAt;

  const XpHistoryEntry({
    required this.id,
    required this.userId,
    required this.xpAmount,
    required this.source,
    required this.sourceId,
    required this.earnedAt,
  });
}

/// Origem do XP recebido.
enum XpSource {
  /// XP ganho ao concluir uma lição.
  lessonCompleted,

  /// XP ganho ao concluir um desafio.
  challengeCompleted,

  /// XP bônus por manter streak diário.
  dailyStreak,

  /// XP ganho ao desbloquear uma conquista.
  achievementUnlocked,

  /// XP ganho por manter sequência longa de dias.
  streakBonus,
}
