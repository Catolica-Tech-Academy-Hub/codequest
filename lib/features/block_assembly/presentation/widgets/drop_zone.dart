import 'package:flutter/material.dart';

import 'package:codequest/features/block_assembly/domain/entities/logic_block.dart';

/// Widget que representa uma zona onde blocos podem ser soltos (drop zone).
///
/// Camada: presentation/widgets — apenas renderização.
///
/// Responsabilidades:
/// - Aceitar blocos arrastados
/// - Exibir feedback visual de "aceita drop"
/// - Chamar callback quando bloco é solto
class DropZone extends StatefulWidget {
  const DropZone({
    super.key,
    required this.position,
    required this.expectedBlock,
    required this.currentBlock,
    required this.onAccept,
    this.isHighlighted = false,
    this.hasError = false,
  });

  /// Posição esperada nesta zona (1-indexed para exibição).
  final int position;

  /// Bloco que deveria estar nesta posição (para validação).
  final LogicBlock? expectedBlock;

  /// Bloco atualmente nesta zona (null se vazio).
  final LogicBlock? currentBlock;

  /// Callback quando um bloco é solto nesta zona.
  final Function(LogicBlock block) onAccept;

  /// Se a zona está destacada (por validação ou interação).
  final bool isHighlighted;

  /// Se a zona tem um erro de validação.
  final bool hasError;

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color borderColor;
    double elevation = 0;

    if (widget.hasError) {
      backgroundColor = colorScheme.errorContainer.withOpacity(0.3);
      borderColor = colorScheme.error;
      elevation = 2;
    } else if (_isHovering) {
      backgroundColor = colorScheme.primaryContainer.withOpacity(0.2);
      borderColor = colorScheme.primary;
      elevation = 4;
    } else if (widget.isHighlighted) {
      backgroundColor = colorScheme.secondaryContainer.withOpacity(0.15);
      borderColor = colorScheme.secondary;
    } else {
      backgroundColor = colorScheme.surfaceContainerHighest.withOpacity(0.5);
      borderColor = colorScheme.outlineVariant;
    }

    return DragTarget<LogicBlock>(
      onWillAcceptWithDetails: (data) {
        setState(() => _isHovering = true);
        return true;
      },
      onLeave: (data) {
        setState(() => _isHovering = false);
      },
      onAcceptWithDetails: (block) {
        setState(() => _isHovering = false);
        widget.onAccept(block);
      },
      builder: (context, candidateData, rejectedData) {
        final isAcceptingDrop = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: borderColor,
              width: isAcceptingDrop ? 2 : 1.5,
              style: isAcceptingDrop
                  ? BorderStyle.solid
                  : BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (elevation > 0)
                BoxShadow(
                  color: borderColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {}, // Feedback apenas
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Posição
                    Text(
                      'Posição ${widget.position}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Conteúdo central: bloco atual ou placeholder
                    if (widget.currentBlock != null) ...[
                      _buildBlockPreview(context, widget.currentBlock!),
                    ] else ...[
                      _buildEmptyPlaceholder(context, isAcceptingDrop),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Exibe o bloco atualmente nesta zona.
  Widget _buildBlockPreview(BuildContext context, LogicBlock block) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCorrect = widget.expectedBlock?.id.value == block.id.value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCorrect
            ? colorScheme.tertiaryContainer.withOpacity(0.6)
            : colorScheme.errorContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect
              ? colorScheme.tertiary
              : colorScheme.error,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.error,
            size: 16,
            color: isCorrect
                ? colorScheme.tertiary
                : colorScheme.error,
          ),
          const SizedBox(width: 6),
          Text(
            block.label.value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isCorrect
                  ? colorScheme.onTertiaryContainer
                  : colorScheme.onErrorContainer,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Exibe placeholder quando a zona está vazia.
  Widget _buildEmptyPlaceholder(BuildContext context, bool isAccepting) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Icon(
      isAccepting ? Icons.download_done : Icons.cloud_upload_outlined,
      size: 28,
      color: colorScheme.onSurfaceVariant.withOpacity(
        isAccepting ? 0.8 : 0.4,
      ),
    );
  }
}
