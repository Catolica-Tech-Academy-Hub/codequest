import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_achievement.dart';
import '../../providers/achievement_providers.dart';
import '../widgets/achievement_card.dart';
import '../widgets/xp_history_tile.dart';

/// Tela principal do módulo de Conquistas.
///
/// Exibe a lista de conquistas do usuário e o histórico de XP.
class AchievementsScreen extends ConsumerWidget {
  final String userId;

  const AchievementsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(userAchievementsProvider(userId));
    final xpAsync = ref.watch(xpHistoryProvider(userId));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Conquistas'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Conquistas'),
              Tab(text: 'Histórico de XP'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ── Aba de Conquistas ────────────────────────────────────────────
            achievementsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (achievements) => _AchievementsList(achievements: achievements),
            ),

            // ── Aba de Histórico de XP ───────────────────────────────────────
            xpAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (history) => history.isEmpty
                  ? const Center(child: Text('Nenhum XP registrado ainda.'))
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) =>
                          XpHistoryTile(entry: history[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementsList extends StatelessWidget {
  final List<UserAchievement> achievements;

  const _AchievementsList({required this.achievements});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievements.where((a) => a.isUnlocked).toList();
    final locked = achievements.where((a) => !a.isUnlocked).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (unlocked.isNotEmpty) ...[
          Text(
            'Desbloqueadas (${unlocked.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...unlocked.map((ua) => AchievementCard(userAchievement: ua)),
          const SizedBox(height: 24),
        ],
        if (locked.isNotEmpty) ...[
          Text(
            'Em progresso (${locked.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...locked.map((ua) => AchievementCard(userAchievement: ua)),
        ],
      ],
    );
  }
}
