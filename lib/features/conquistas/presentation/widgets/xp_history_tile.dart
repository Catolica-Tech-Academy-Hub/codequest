import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/xp_history_entry.dart';

/// Tile que exibe uma entrada do histórico de XP.
class XpHistoryTile extends StatelessWidget {
  final XpHistoryEntry entry;

  const XpHistoryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          '+${entry.xpAmount}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      title: Text(_sourceLabel(entry.source)),
      subtitle: Text(
        DateFormat('dd/MM/yyyy HH:mm').format(entry.earnedAt),
        style: Theme.of(context).textTheme.labelSmall,
      ),
      trailing: Text(
        '+${entry.xpAmount} XP',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _sourceLabel(XpSource source) {
    return switch (source) {
      XpSource.lessonCompleted => 'Lição concluída',
      XpSource.challengeCompleted => 'Desafio concluído',
      XpSource.dailyStreak => 'Bônus de streak diário',
      XpSource.achievementUnlocked => 'Conquista desbloqueada',
      XpSource.streakBonus => 'Bônus de sequência longa',
    };
  }
}
