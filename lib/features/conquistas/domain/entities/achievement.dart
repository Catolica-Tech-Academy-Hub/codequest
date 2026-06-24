/// Representa uma conquista que o usuário pode desbloquear.
///
/// Esta entidade é pura: não depende de Firebase, Flutter ou qualquer
/// detalhe de infraestrutura — conforme as regras do projeto.
class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final int xpReward;
  final String iconPath;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.xpReward,
    required this.iconPath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Achievement && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

/// Tipo de conquista, define a categoria do gatilho que a desbloqueia.
enum AchievementType {
  /// Desbloqueada por acumular uma quantidade de XP.
  xpMilestone,

  /// Desbloqueada por manter uma sequência de dias consecutivos (streak).
  streak,

  /// Desbloqueada ao concluir uma trilha inteira.
  trailCompleted,

  /// Desbloqueada ao atingir uma posição no ranking.
  ranking,

  /// Desbloqueada ao completar um número específico de lições.
  lessonsCompleted,
}
