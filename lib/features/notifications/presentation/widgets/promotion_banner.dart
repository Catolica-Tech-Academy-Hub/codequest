import 'package:codequest/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

const _tierLabels = {
  'silver': 'Prata',
  'gold': 'Ouro',
  'diamond': 'Diamante',
};

const _tierColors = {
  'silver': AppColors.silver,
  'gold': AppColors.gold,
  'diamond': AppColors.diamond,
};

MaterialBanner buildPromotionBanner({
  required BuildContext context,
  required String newTier,
  required VoidCallback onViewRanking,
  required VoidCallback onDismiss,
}) {
  final label = _tierLabels[newTier] ?? newTier;
  final color = _tierColors[newTier] ?? AppColors.bronze;
  final theme = Theme.of(context);

  return MaterialBanner(
    padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
    backgroundColor: color.withValues(alpha: 0.15),
    leading: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.emoji_events, color: Colors.amber, size: 26),
    ),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Parabéns!',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Você foi promovido para a liga $label!',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: onViewRanking,
        child: const Text('VER RANKING'),
      ),
      TextButton(
        onPressed: onDismiss,
        child: const Text('FECHAR'),
      ),
    ],
  );
}
