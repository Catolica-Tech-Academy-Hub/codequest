import 'package:flutter/material.dart';

/// Indicador de progresso mostrando quantas linhas estão na posição correta.
class SortingProgressIndicator extends StatelessWidget {
  const SortingProgressIndicator({
    super.key,
    required this.correctCount,
    required this.totalCount,
  });

  final int correctCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = totalCount == 0 ? 0.0 : correctCount / totalCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progresso',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$correctCount / $totalCount corretas',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                progress == 1.0 ? Colors.green : colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Overlay de feedback de sucesso exibido ao acertar.
class SortingSuccessOverlay extends StatelessWidget {
  const SortingSuccessOverlay({
    super.key,
    required this.xpEarned,
    required this.onDismiss,
  });

  final int xpEarned;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 72),
          const SizedBox(height: 16),
          Text(
            'Código ordenado!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Você organizou todas as linhas corretamente.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, size: 20),
                const SizedBox(width: 6),
                Text(
                  '+$xpEarned XP',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onDismiss,
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}

/// Widget de tentativas restantes.
class RemainingAttemptsIndicator extends StatelessWidget {
  const RemainingAttemptsIndicator({
    super.key,
    required this.used,
    required this.max,
  });

  final int used;
  final int max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final remaining = max - used;

    return Row(
      children: [
        Icon(
          Icons.repeat_rounded,
          size: 16,
          color: remaining <= 1 ? colorScheme.error : colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          'Tentativas restantes: $remaining/$max',
          style: theme.textTheme.labelMedium?.copyWith(
            color: remaining <= 1 ? colorScheme.error : colorScheme.onSurfaceVariant,
            fontWeight: remaining <= 1 ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
