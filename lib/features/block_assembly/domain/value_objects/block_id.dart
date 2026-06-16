import 'package:equatable/equatable.dart';

/// Value Object que representa o identificador único de um bloco lógico.
///
/// Camada: domain — sem dependências externas.
class BlockId extends Equatable {
  const BlockId(this.value);

  final String value;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'BlockId($value)';
}
