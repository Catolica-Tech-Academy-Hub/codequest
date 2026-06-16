import 'package:flutter/material.dart';

enum FeedbackStatus { correct, wrong }

Future<void> showFeedbackModal(
  BuildContext context, {
  required FeedbackStatus status,
  required String message,
  required VoidCallback onContinue,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (ctx) => FeedbackModal(
      status: status,
      message: message,
      onContinue: () {
        Navigator.of(ctx).pop();
        onContinue();
      },
    ),
  );
}

class FeedbackModal extends StatelessWidget {
  const FeedbackModal({
    required this.status,
    required this.message,
    required this.onContinue,
    super.key,
  });

  final FeedbackStatus status;
  final String message;
  final VoidCallback onContinue;

  static const double _circleSize = 72;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(status);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        top: _circleSize / 2,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              24,
              _circleSize / 2 + 16,
              24,
              24 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  palette.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onContinue,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'CONTINUAR',
                      style: theme.textTheme.labelLarge?.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -_circleSize / 2,
            child: Container(
              width: _circleSize,
              height: _circleSize,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: palette.color, width: 2.5),
              ),
              alignment: Alignment.center,
              child: Icon(palette.icon, size: 40, color: palette.color),
            ),
          ),
        ],
      ),
    );
  }

  _FeedbackPalette _paletteFor(FeedbackStatus status) {
    return switch (status) {
      FeedbackStatus.correct => const _FeedbackPalette(
          title: 'Excelente!',
          icon: Icons.check,
          color: Color(0xFF34A853),
        ),
      FeedbackStatus.wrong => const _FeedbackPalette(
          title: 'Incorreto',
          icon: Icons.close,
          color: Color(0xFFD93025),
        ),
    };
  }
}

class _FeedbackPalette {
  const _FeedbackPalette({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;
}
