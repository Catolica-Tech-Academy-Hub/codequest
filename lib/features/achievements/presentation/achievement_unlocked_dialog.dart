import 'package:codequest/features/achievements/domain/entities/achievement.dart';
import 'package:codequest/features/achievements/presentation/achievement_tier_style.dart';
import 'package:flutter/material.dart';

Future<void> showAchievementUnlockedDialog(
  BuildContext context,
  Achievement achievement,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => _AchievementUnlockedDialog(achievement: achievement),
  );
}

class _AchievementUnlockedDialog extends StatelessWidget {
  const _AchievementUnlockedDialog({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = AchievementTierStyle.of(achievement.tier);

    return AlertDialog(
      title: Row(
        children: <Widget>[
          Icon(achievementIcon(achievement.iconKey), color: style.color),
          const SizedBox(width: 8),
          const Expanded(child: Text('Conquista desbloqueada')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            achievement.name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            style.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: style.color,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            achievement.description,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}
