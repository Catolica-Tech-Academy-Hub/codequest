import 'package:equatable/equatable.dart';

/// Value Object que representa o rótulo/conteúdo visual de um bloco.
///
/// Camada: domain — sem dependências externas.
class BlockLabel extends Equatable {
  const BlockLabel(this.value);

  final String value;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'BlockLabel($value)';
}
