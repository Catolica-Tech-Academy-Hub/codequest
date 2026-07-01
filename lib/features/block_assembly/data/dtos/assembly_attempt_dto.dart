import 'package:codequest/features/block_assembly/domain/entities/assembly_attempt.dart';
import 'package:codequest/features/block_assembly/domain/value_objects/block_id.dart';

/// DTO que mapeia uma tentativa de montagem do Firestore para entidade de domínio.
///
/// Camada: data — serialização e mapeamento de dados externos.
///
/// Campos esperados no Firestore:
///   id                      : String
///   challengeId             : String
///   userId                  : String
///   selectedBlockSequence   : List<String> (IDs dos blocos na ordem escolhida)
///   isCorrect               : bool
///   attemptNumber           : int
///   createdAt               : Timestamp
///   xpEarned                : int (opcional, padrão 0)
///   feedback                : String (opcional, padrão '')
class AssemblyAttemptDto {
  const AssemblyAttemptDto({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.selectedBlockSequence,
    required this.isCorrect,
    required this.attemptNumber,
    required this.createdAt,
    this.xpEarned = 0,
    this.feedback = '',
  });

  final String id;
  final String challengeId;
  final String userId;
  final List<String> selectedBlockSequence;
  final bool isCorrect;
  final int attemptNumber;
  final DateTime createdAt;
  final int xpEarned;
  final String feedback;

  /// Converte DTO para entidade de domínio.
  AssemblyAttempt toDomain() {
    return AssemblyAttempt(
      id: id,
      challengeId: challengeId,
      userId: userId,
      selectedBlockSequence: selectedBlockSequence.map(BlockId.new).toList(),
      isCorrect: isCorrect,
      attemptNumber: attemptNumber,
      createdAt: createdAt,
      xpEarned: xpEarned,
      feedback: feedback,
    );
  }

  /// Cria DTO a partir de Map (Firestore doc).
  factory AssemblyAttemptDto.fromFirestore(Map<String, dynamic> data) {
    final blockSeq = (data['selectedBlockSequence'] as List<dynamic>?)
        ?.cast<String>() ?? [];

    return AssemblyAttemptDto(
      id: (data['id'] as String?) ?? '',
      challengeId: (data['challengeId'] as String?) ?? '',
      userId: (data['userId'] as String?) ?? '',
      selectedBlockSequence: blockSeq,
      isCorrect: (data['isCorrect'] as bool?) ?? false,
      attemptNumber: (data['attemptNumber'] as int?) ?? 1,
      createdAt: (data['createdAt'] as DateTime?) ?? DateTime.now(),
      xpEarned: (data['xpEarned'] as int?) ?? 0,
      feedback: (data['feedback'] as String?) ?? '',
    );
  }

  /// Converte DTO para Map para salvar no Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'challengeId': challengeId,
      'userId': userId,
      'selectedBlockSequence': selectedBlockSequence,
      'isCorrect': isCorrect,
      'attemptNumber': attemptNumber,
      'createdAt': createdAt,
      'xpEarned': xpEarned,
      'feedback': feedback,
    };
  }
}
