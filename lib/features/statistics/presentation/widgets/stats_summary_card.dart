import 'package:flutter/material.dart';

import 'package:codequest/features/statistics/domain/player_stats.dart';

/// Cartão de desempenho individual (RF03): posição, XP total e sequência.
class StatsSummaryCard extends StatelessWidget {
  const StatsSummaryCard({super.key, required this.stats});

  final PlayerStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          _StatTile(
            icon: '🏅',
            label: 'Posição',
            value: '#${stats.position}',
            trailing: _PositionDelta(change: stats.positionChange),
          ),
          _divider(colorScheme),
          _StatTile(
            icon: '⚡',
            label: 'XP Total',
            value: '${stats.xpTotal}',
          ),
          _divider(colorScheme),
          _StatTile(
            icon: '🔥',
            label: 'Sequência',
            value: '${stats.streakDays}d',
          ),
        ],
      ),
    );
  }

  Widget _divider(ColorScheme colorScheme) {
    return Container(
      width: 1,
      height: 44,
      color: colorScheme.primary.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final String icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          FittedBox(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 4),
                  trailing!,
                ],
              ],
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _PositionDelta extends StatelessWidget {
  const _PositionDelta({required this.change});

  final int change;

  @override
  Widget build(BuildContext context) {
    if (change == 0) return const SizedBox.shrink();
    final up = change > 0;
    final color = up ? Colors.green : Colors.red;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          up ? Icons.arrow_upward : Icons.arrow_downward,
          size: 12,
          color: color,
        ),
        Text(
          '${change.abs()}',
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
