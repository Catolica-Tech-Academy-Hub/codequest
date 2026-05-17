import 'package:codequest/features/activities/domain/entities/activity.dart';
import 'package:codequest/features/activities/presentation/widgets/rich_activity_text.dart';
import 'package:flutter/material.dart';

class ContentActivityWidget extends StatelessWidget {
  const ContentActivityWidget({
    required this.activity,
    required this.onContinue,
    super.key,
  });

  final ContentActivity activity;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
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
        RichActivityText(activity.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 16),
        RichActivityText(
          activity.body,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onContinue,
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}
