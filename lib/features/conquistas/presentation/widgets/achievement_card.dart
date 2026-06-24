import 'package:flutter/material.dart';
import '../../domain/entities/user_achievement.dart';

/// Card que exibe uma conquista com seu estado de progresso.
class AchievementCard extends StatelessWidget {
  final UserAchievement userAchievement;

  const AchievementCard({super.key, required this.userAchievement});

  @override
  Widget build(BuildContext context) {
    final ua = userAchievement;
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: ua.isUnlocked ? colors.primaryContainer : colors.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Ícone da conquista.
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ua.isUnlocked ? colors.primary : colors.outline,
              ),
              child: Icon(
                ua.isUnlocked ? Icons.emoji_events : Icons.lock_outline,
                color: ua.isUnlocked ? colors.onPrimary : colors.onSurface,
              ),
            ),
            const SizedBox(width: 16),

            // Título, descrição e barra de progresso.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ua.achievement.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ua.isUnlocked
                              ? colors.onPrimaryContainer
                              : colors.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ua.achievement.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  if (!ua.isUnlocked) ...[
                    LinearProgressIndicator(
                      value: ua.progressPercent,
                      backgroundColor: colors.surfaceVariant,
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ua.currentProgress} / ${ua.targetProgress}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ] else
                    Text(
                      '+ ${ua.achievement.xpReward} XP',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
