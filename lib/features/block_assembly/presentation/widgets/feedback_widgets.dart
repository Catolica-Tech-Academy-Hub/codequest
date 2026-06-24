import 'package:flutter/material.dart';

/// Widget que exibe feedback visual sobre o resultado de uma tentativa.
///
/// Camada: presentation/widgets — apenas renderização.
class FeedbackOverlay extends StatefulWidget {
  const FeedbackOverlay({
    super.key,
    required this.isSuccess,
    required this.message,
    required this.xpEarned,
    this.onDismiss,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  final bool isSuccess;
  final String message;
  final int xpEarned;
  final VoidCallback? onDismiss;
  final Duration animationDuration;

  @override
  State<FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<FeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    // Auto-dismiss após 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final backgroundColor = widget.isSuccess
        ? colorScheme.tertiaryContainer
        : colorScheme.errorContainer;
    final textColor = widget.isSuccess
        ? colorScheme.onTertiaryContainer
        : colorScheme.onErrorContainer;
    final iconData = widget.isSuccess ? Icons.check_circle : Icons.error;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone
              Icon(
                iconData,
                size: 48,
                color: textColor,
              ),
              const SizedBox(height: 16),

              // Mensagem
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),

              // XP ganhado
              if (widget.xpEarned > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '+${widget.xpEarned} XP',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget que exibe erros com destaque nas posições incorretas.
///
/// Camada: presentation/widgets — apenas renderização.
class ValidationErrorWidget extends StatelessWidget {
  const ValidationErrorWidget({
    super.key,
    required this.errorPositions,
    required this.totalPositions,
    this.onRetry,
  });

  final Set<int> errorPositions;
  final int totalPositions;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (errorPositions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.2),
        border: Border.all(
          color: colorScheme.error,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                size: 20,
                color: colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Erro em ${errorPositions.length} posição(ões)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'As posições com erro estão destacadas em vermelho.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onErrorContainer.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget mostrando quantas tentativas restam.
///
/// Camada: presentation/widgets — apenas renderização.
class RemainingAttemptsWidget extends StatelessWidget {
  const RemainingAttemptsWidget({
    super.key,
    required this.current,
    required this.max,
  });

  final int current;
  final int max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final remaining = max - current;
    final percentage = remaining / max;

    // Cor muda conforme tentativas diminuem
    Color indicatorColor;
    if (percentage > 0.5) {
      indicatorColor = colorScheme.primary;
    } else if (percentage > 0.25) {
      indicatorColor = Colors.orange;
    } else {
      indicatorColor = colorScheme.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.15),
        border: Border.all(color: indicatorColor, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, size: 16, color: indicatorColor),
          const SizedBox(width: 6),
          Text(
            '$remaining / $max tentativas',
            style: theme.textTheme.labelSmall?.copyWith(
              color: indicatorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
