import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:codequest/features/statistics/presentation/widgets/stats_summary_card.dart';
import 'package:codequest/features/statistics/presentation/widgets/xp_evolution_chart.dart';
import 'package:codequest/features/statistics/presentation/widgets/xp_history_list.dart';
import 'package:codequest/features/statistics/providers/statistics_providers.dart';

/// Tela de estatísticas e evolução temporal do jogador (RF03/RF07).
class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  static const int _weeks = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(playerStatsProvider);
    final historyAsync = ref.watch(xpHistoryProvider(_weeks));

    return Scaffold(
      appBar: AppBar(title: const Text('Estatísticas')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(playerStatsProvider);
          ref.invalidate(xpHistoryProvider(_weeks));
          await Future.wait([
            ref.read(playerStatsProvider.future),
            ref.read(xpHistoryProvider(_weeks).future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Desempenho individual.
            statsAsync.when(
              loading: () => const _LoadingBox(height: 96),
              error: (e, _) => _ErrorBox(
                message: 'Não foi possível carregar o desempenho.',
                onRetry: () => ref.invalidate(playerStatsProvider),
              ),
              data: (stats) => StatsSummaryCard(stats: stats),
            ),
            const SizedBox(height: 24),

            Text('Evolução de XP', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),

            // Evolução temporal (gráfico + lista).
            historyAsync.when(
              loading: () => const _LoadingBox(height: 220),
              error: (e, _) => _ErrorBox(
                message: 'Não foi possível carregar o histórico.',
                onRetry: () => ref.invalidate(xpHistoryProvider(_weeks)),
              ),
              data: (entries) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  XpEvolutionChart(entries: entries),
                  const SizedBox(height: 24),
                  Text('Detalhes por semana', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  XpHistoryList(entries: entries),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }
}
