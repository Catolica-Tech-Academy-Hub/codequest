import 'package:codequest/features/achievements/presentation/achievement_unlocked_dialog.dart';
import 'package:codequest/features/achievements/providers/achievements_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dispara a verificação de conquistas no servidor e exibe um modal para cada
/// conquista desbloqueada.
///
/// Falhas são engolidas de propósito: conquista é efeito colateral e não pode
/// derrubar o fluxo que a acionou (entrar no jogo / concluir uma fase).
Future<void> triggerAchievementsCheck(WidgetRef ref, BuildContext context) async {
  try {
    final unlocked = await ref.read(checkAchievementsActionProvider).call();
    debugPrint('[achievements] check -> ${unlocked.map((a) => a.id).toList()}');
    for (final achievement in unlocked) {
      if (!context.mounted) {
        return;
      }
      await showAchievementUnlockedDialog(context, achievement);
    }
  } catch (error, stack) {
    debugPrint('[achievements] check FAILED: $error\n$stack');
    // Silencioso por design (ver doc acima).
  }
}
