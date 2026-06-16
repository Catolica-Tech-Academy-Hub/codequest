import 'package:codequest/features/levels/presentation/widgets/rich_level_text.dart';
import 'package:flutter/material.dart';

enum AnswerTileState { idle, selected, correct, incorrect, missed }

class AnswerOptionTile extends StatelessWidget {
  const AnswerOptionTile({
    required this.label,
    required this.text,
    required this.state,
    required this.onTap,
    super.key,
  });

  final String label;
  final String text;
  final AnswerTileState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _colorsFor(theme);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border, width: 1.5),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.badge,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    label.toUpperCase(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.badgeText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichLevelText(
                    text,
                    style: theme.textTheme.bodyLarge?.copyWith(color: colors.text),
                  ),
                ),
                if (state == AnswerTileState.correct)
                  Icon(Icons.check_circle, color: colors.icon),
                if (state == AnswerTileState.incorrect)
                  Icon(Icons.cancel, color: colors.icon),
                if (state == AnswerTileState.missed)
                  Icon(Icons.error_outline, color: colors.icon),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _TileColors _colorsFor(ThemeData theme) {
    switch (state) {
      case AnswerTileState.idle:
        return _TileColors(
          background: theme.colorScheme.surface,
          border: theme.colorScheme.outlineVariant,
          badge: theme.colorScheme.surfaceContainerHighest,
          badgeText: theme.colorScheme.onSurface,
          text: theme.colorScheme.onSurface,
          icon: theme.colorScheme.onSurface,
        );
      case AnswerTileState.selected:
        return _TileColors(
          background: theme.colorScheme.primaryContainer,
          border: theme.colorScheme.primary,
          badge: theme.colorScheme.primary,
          badgeText: theme.colorScheme.onPrimary,
          text: theme.colorScheme.onPrimaryContainer,
          icon: theme.colorScheme.primary,
        );
      case AnswerTileState.correct:
        return const _TileColors(
          background: Color(0xFFE6F4EA),
          border: Color(0xFF34A853),
          badge: Color(0xFF34A853),
          badgeText: Colors.white,
          text: Color(0xFF1E4620),
          icon: Color(0xFF34A853),
        );
      case AnswerTileState.incorrect:
        return const _TileColors(
          background: Color(0xFFFCE8E6),
          border: Color(0xFFD93025),
          badge: Color(0xFFD93025),
          badgeText: Colors.white,
          text: Color(0xFF5F1A17),
          icon: Color(0xFFD93025),
        );
      case AnswerTileState.missed:
        return const _TileColors(
          background: Color(0xFFFEF7E0),
          border: Color(0xFFF9AB00),
          badge: Color(0xFFF9AB00),
          badgeText: Colors.white,
          text: Color(0xFF5F4500),
          icon: Color(0xFFF9AB00),
        );
    }
  }
}

class _TileColors {
  const _TileColors({
    required this.background,
    required this.border,
    required this.badge,
    required this.badgeText,
    required this.text,
    required this.icon,
  });

  final Color background;
  final Color border;
  final Color badge;
  final Color badgeText;
  final Color text;
  final Color icon;
}
