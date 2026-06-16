import 'package:flutter/material.dart';

class LevelNode extends StatelessWidget {
  const LevelNode({
    required this.index,
    required this.alignment,
    required this.accent,
    required this.onTap,
    this.showConnector = false,
    super.key,
  });

  final int index;
  final Alignment alignment;
  final Color accent;
  final VoidCallback onTap;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: <Widget>[
        if (showConnector)
          Container(
            width: 4,
            height: 28,
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Align(
            alignment: alignment,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Container(
                width: 84,
                height: 84,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accent, Color.lerp(accent, Colors.black, 0.35)!],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 3,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: accent.withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  '$index',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
