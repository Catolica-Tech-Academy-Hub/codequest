import 'package:flutter/material.dart';

enum FeedbackStatus { correct, wrong }

Future<void> showFeedbackModal(
    BuildContext context, {
      required FeedbackStatus status,
      String? message,
      int? xp,
      VoidCallback? onContinue,
    }) async {
  return showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => FeedbackModal(
      status: status,
      message: message,
      xp: xp,
      onContinue: onContinue ?? () => Navigator.of(context).pop(),
    ),
  );
}

class FeedbackModal extends StatelessWidget {
  final FeedbackStatus status;
  final String? message;
  final int? xp;
  final VoidCallback onContinue;

  const FeedbackModal({
    Key? key,
    required this.status,
    this.message,
    this.xp,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCorrect = status == FeedbackStatus.correct;
    final backgroundColor = isCorrect ? Colors.green : Colors.red;
    final title = isCorrect ? 'Excelente!' : 'Incorreto!';
    final icon = isCorrect ? Icons.check_circle_outline : Icons.error_outline;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: backgroundColor, size: 72),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: backgroundColor,
            ),
          ),
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
          if (isCorrect && xp != null && xp! > 0) ...[
            const SizedBox(height: 12),
            Text(
              '+$xp XP',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onContinue,
              child: const Text(
                'Continuar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}