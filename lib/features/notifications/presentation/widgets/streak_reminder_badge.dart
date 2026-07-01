import 'package:flutter/material.dart';

class StreakReminderBadge extends StatelessWidget {
  const StreakReminderBadge({required this.active, super.key});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          active ? Icons.notifications_active : Icons.notifications_off_outlined,
          size: 18,
          color: active ? Colors.orange : theme.colorScheme.outline,
        ),
        const SizedBox(width: 6),
        Text(
          active ? 'Lembrete de streak ativo' : 'Lembrete de streak desativado',
          style: theme.textTheme.bodySmall?.copyWith(
            color: active ? Colors.orange : theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
