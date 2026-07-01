import 'dart:async';

import 'package:codequest/features/levels/domain/entities/level.dart';
import 'package:codequest/features/levels/presentation/widgets/rich_level_text.dart';
import 'package:codequest/features/xp/providers/xp_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContentLevelWidget extends ConsumerWidget {
  const ContentLevelWidget({
    required this.level,
    required this.onContinue,
    super.key,
  });

  final ContentLevel level;
  final VoidCallback onContinue;

  void _onContinue(WidgetRef ref) {
    unawaited(ref.read(xpControllerProvider).awardForLevel(level: level));
    onContinue();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            'CONTEÚDO',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        RichLevelText(level.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 16),
        RichLevelText(
          level.body,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => _onContinue(ref),
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}
