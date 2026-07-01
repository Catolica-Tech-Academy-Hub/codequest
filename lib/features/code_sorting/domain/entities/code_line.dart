import 'package:equatable/equatable.dart';

import 'package:codequest/features/code_sorting/domain/value_objects/line_id.dart';

/// Representa uma linha de código individual no desafio de ordenação.
///
/// Camada: domain — sem dependências externas.
class CodeLine extends Equatable {
  const CodeLine({
    required this.id,
    required this.content,
    required this.expectedPosition,
    this.indentLevel = 0,
  });

  final LineId id;

  /// Conteúdo textual da linha de código.
  final String content;

  /// Posição correta na sequência (0-indexed).
  final int expectedPosition;

  /// Nível de indentação (0 = sem indentação).
  final int indentLevel;

  @override
  List<Object?> get props => [id, content, expectedPosition, indentLevel];

  @override
  String toString() => 'CodeLine(id: $id, pos: $expectedPosition)';
}
