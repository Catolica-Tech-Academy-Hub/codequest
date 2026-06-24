import '../../domain/entities/logic_block.dart';
import '../../domain/value_objects/block_id.dart';
import '../../domain/value_objects/block_label.dart';

/// DTO que mapeia um bloco lógico do Firestore para entidade de domínio.
///
/// Camada: data — serialização e mapeamento de dados externos.
///
/// Campos esperados no Firestore:
///   id              : String
///   label           : String
///   expectedPosition : int
class LogicBlockDto {
  const LogicBlockDto({
    required this.id,
    required this.label,
    required this.expectedPosition,
  });

  final String id;
  final String label;
  final int expectedPosition;

  /// Converte DTO para entidade de domínio.
  LogicBlock toDomain() {
    return LogicBlock(
      id: BlockId(id),
      label: BlockLabel(label),
      expectedPosition: expectedPosition,
    );
  }

  /// Cria DTO a partir de Map (Firestore doc).
  factory LogicBlockDto.fromFirestore(Map<String, dynamic> data) {
    return LogicBlockDto(
      id: (data['id'] as String?) ?? '',
      label: (data['label'] as String?) ?? '',
      expectedPosition: (data['expectedPosition'] as int?) ?? 0,
    );
  }

  /// Converte DTO para Map para salvar no Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'label': label,
      'expectedPosition': expectedPosition,
    };
  }
}
