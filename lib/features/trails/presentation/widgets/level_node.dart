import 'package:flutter/material.dart';

class LevelNode extends StatelessWidget {
  const LevelNode({
    required this.index,
    required this.alignment,
    required this.onTap,
    this.isLocked = false,
    super.key,
  });

  final int index;
  final Alignment alignment;
  final VoidCallback onTap;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isLocked ? Colors.grey : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
      child: Align(
        alignment: alignment,
        child: InkWell(
          onTap: isLocked ? null : onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                if (!isLocked)
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            child: Text(
              '$index',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: isLocked ? Colors.white70 : theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
