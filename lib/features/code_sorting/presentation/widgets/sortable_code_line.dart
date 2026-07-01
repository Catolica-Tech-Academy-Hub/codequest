import 'package:flutter/material.dart';

import 'package:codequest/features/code_sorting/domain/entities/code_line.dart';

/// Widget que representa uma linha de código arrastável.
///
/// Camada: presentation/widgets — apenas renderização.
class SortableCodeLine extends StatelessWidget {
  const SortableCodeLine({
    super.key,
    required this.line,
    required this.index,
    this.hasError = false,
    this.isCorrect = false,
  });

  final CodeLine line;
  final int index;
  final bool hasError;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color borderColor;
    Color backgroundColor;
    if (hasError) {
      borderColor = colorScheme.error;
      backgroundColor = colorScheme.errorContainer.withOpacity(0.3);
    } else if (isCorrect) {
      borderColor = Colors.green;
      backgroundColor = Colors.green.withOpacity(0.08);
    } else {
      borderColor = colorScheme.outlineVariant;
      backgroundColor = colorScheme.surfaceContainerHigh;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Número da posição atual
          Container(
            width: 36,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: Text(
              '${index + 1}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Conteúdo da linha de código
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: 8.0 + line.indentLevel * 16.0,
                right: 8,
                top: 12,
                bottom: 12,
              ),
              child: Text(
                line.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ),

          // Ícone de status
          if (hasError || isCorrect)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                hasError ? Icons.close_rounded : Icons.check_rounded,
                size: 18,
                color: hasError ? colorScheme.error : Colors.green,
              ),
            ),

          // Handle de drag
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              Icons.drag_handle_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
