import 'package:codequest/features/achievements/domain/entities/achievement_status.dart';
import 'package:codequest/features/achievements/presentation/achievement_tier_style.dart';
import 'package:codequest/features/achievements/providers/achievements_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statuses = ref.watch(achievementStatusesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Conquistas')),
      body: statuses.when(
        data: (items) => _AchievementsList(items: items),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Não foi possível carregar as conquistas.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _AchievementsList extends StatelessWidget {
  const _AchievementsList({required this.items});

  final List<AchievementStatus> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Nenhuma conquista no catálogo.'));
    }

    final unlockedCount = items.where((item) => item.unlocked).length;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '$unlockedCount de ${items.length} desbloqueadas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }
        return _AchievementCard(status: items[index - 1]);
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.status});

  final AchievementStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final achievement = status.achievement;
    final style = AchievementTierStyle.of(achievement.tier);
    final unlocked = status.unlocked;

    // Bloqueada: dessaturada e com cadeado; desbloqueada: cor cheia do tier.
    final accent = unlocked ? style.color : theme.disabledColor;

    return Opacity(
      opacity: unlocked ? 1 : 0.6,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: accent.withValues(alpha: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: accent.withValues(alpha: 0.15),
                foregroundColor: accent,
                child: Icon(
                  unlocked ? achievementIcon(achievement.iconKey) : Icons.lock,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      achievement.name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      style.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      achievement.description,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (unlocked)
                Icon(Icons.check_circle, color: style.color),
            ],
          ),
        ),
      ),
    );
  }
}
