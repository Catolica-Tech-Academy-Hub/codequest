import 'package:codequest/features/levels/domain/entities/level.dart';
import 'package:codequest/features/levels/presentation/widgets/rich_level_text.dart';
import 'package:flutter/material.dart';

/// Exibe a Teoria (RF05) como um pop-up antes do exercício.
///
/// Bloqueante por design (`barrierDismissible: false`): o usuário lê a
/// explicação e toca em "Começar" para então resolver o exercício.
Future<void> showTheoryDialog(BuildContext context, LevelTheory theory) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => TheoryDialog(theory: theory),
  );
}

class TheoryDialog extends StatelessWidget {
  const TheoryDialog({required this.theory, super.key});

  final LevelTheory theory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _TheoryBadge(theme: theme),
              const SizedBox(height: 12),
              RichLevelText(theory.title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: RichLevelText(
                    theory.body,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Começar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TheoryBadge extends StatelessWidget {
  const _TheoryBadge({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.menu_book_rounded,
              size: 16,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 6),
            Text(
              'TEORIA',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
