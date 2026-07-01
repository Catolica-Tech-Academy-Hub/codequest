import 'package:codequest/features/achievements/domain/entities/achievement.dart';
import 'package:flutter/material.dart';

// O back guarda só o tier (dado semântico); cor/rótulo/ícone são resolvidos aqui
// e reusados tanto no modal de desbloqueio quanto na aba de conquistas.
class AchievementTierStyle {
  const AchievementTierStyle({required this.color, required this.label});

  final Color color;
  final String label;

  static AchievementTierStyle of(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.common:
        return const AchievementTierStyle(color: Color(0xFF6B7280), label: 'COMUM');
      case AchievementTier.rare:
        return const AchievementTierStyle(color: Color(0xFF2563EB), label: 'RARO');
      case AchievementTier.epic:
        return const AchievementTierStyle(color: Color(0xFF7C3AED), label: 'ÉPICO');
      case AchievementTier.legendary:
        return const AchievementTierStyle(color: Color(0xFFD97706), label: 'LENDÁRIO');
    }
  }
}

IconData achievementIcon(String iconKey) {
  switch (iconKey) {
    case 'footprints':
      return Icons.directions_walk;
    case 'medal':
      return Icons.military_tech;
    case 'flame':
      return Icons.local_fire_department;
    case 'fire-crown':
      return Icons.whatshot;
    default:
      return Icons.emoji_events;
  }
}
