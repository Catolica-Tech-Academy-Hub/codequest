import 'package:flutter/material.dart';

import '../../domain/entities/logic_block.dart';

/// Widget que representa um bloco lógico individual que pode ser arrastado.
///
/// Camada: presentation/widgets — apenas renderização.
///
/// Propriedades:
/// - [block] → dados do bloco (id, label, posição esperada)
/// - [isSelected] → indica se está na sequência de destino
/// - [index] → posição no array (para animações)
/// - [onDragStarted] → callback quando inicia o arrasto
class DraggableLogicBlock extends StatelessWidget {
  const DraggableLogicBlock({
    super.key,
    required this.block,
    this.isSelected = false,
    this.index = 0,
    this.onDragStarted,
    this.isDragTarget = false,
  });

  final LogicBlock block;
  final bool isSelected;
  final int index;
  final VoidCallback? onDragStarted;
  final bool isDragTarget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Draggable<LogicBlock>(
      data: block,
      feedback: _buildBlockVisual(
        context,
        isDragging: true,
      ),
      childWhenDragging: _buildBlockVisual(
        context,
        isGhost: true,
      ),
      onDragStarted: onDragStarted,
      child: _buildBlockVisual(context),
    );
  }

  /// Constrói a visualização do bloco com estilos diferentes baseado no estado.
  Widget _buildBlockVisual(
    BuildContext context, {
    bool isDragging = false,
    bool isGhost = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color textColor;
    double elevation = 2;
    double opacity = 1;

    if (isDragging) {
      backgroundColor = colorScheme.primary.withOpacity(0.9);
      textColor = colorScheme.onPrimary;
      elevation = 12;
    } else if (isGhost) {
      backgroundColor = colorScheme.surfaceContainerHighest;
      textColor = colorScheme.onSurfaceVariant;
      opacity = 0.3;
    } else if (isSelected) {
      backgroundColor = colorScheme.secondaryContainer;
      textColor = colorScheme.onSecondaryContainer;
      elevation = 4;
    } else {
      backgroundColor = colorScheme.surfaceContainerHigh;
      textColor = colorScheme.onSurface;
    }

    return Opacity(
      opacity: opacity,
      child: Material(
        elevation: elevation,
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {}, // Feedback visual apenas
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone de drag
                Icon(
                  Icons.drag_indicator,
                  size: 18,
                  color: textColor.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                // Label do bloco
                Text(
                  block.label.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
