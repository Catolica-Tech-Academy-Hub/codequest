import 'package:equatable/equatable.dart';

import '../value_objects/block_id.dart';
import '../value_objects/block_label.dart';

/// Representa um bloco lógico individual no desafio de montagem.
///
/// Camada: domain — sem dependências externas.
///
/// Um bloco é uma unidade atômica que compõe a sequência de solução.
/// Cada bloco possui um ID único, um rótulo visual e uma posição esperada.
class LogicBlock extends Equatable {
  const LogicBlock({
    required this.id,
    required this.label,
    required this.expectedPosition,
  });

  /// Identificador único do bloco.
  final BlockId id;

  /// Rótulo/conteúdo visual do bloco (ex: "while", "let x", "break").
  final BlockLabel label;

  /// Posição esperada na sequência correta (0-indexed).
  final int expectedPosition;

  @override
  List<Object?> get props => [id, label, expectedPosition];

  @override
  String toString() => 'LogicBlock(id: $id, label: $label, pos: $expectedPosition)';
}
