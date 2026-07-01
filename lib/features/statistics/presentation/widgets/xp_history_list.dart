import 'package:flutter/material.dart';

import 'package:codequest/features/statistics/domain/xp_history_entry.dart';

/// Lista detalhada do histórico semanal (mais recente primeiro).
class XpHistoryList extends StatelessWidget {
  const XpHistoryList({super.key, required this.entries});

  final List<XpHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Ainda não há histórico de pontuação.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final entry in entries) _HistoryTile(entry: entry),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final XpHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _weekLabel(entry.weekStart),
              style: theme.textTheme.labelMedium,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Total: ${entry.xpTotal} XP',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            '+${entry.xpGained} XP',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _weekLabel(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return 'Sem. $d/$m';
  }
}
