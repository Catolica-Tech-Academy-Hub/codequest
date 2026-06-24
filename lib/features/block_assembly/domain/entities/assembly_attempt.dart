import 'package:equatable/equatable.dart';

import '../value_objects/block_id.dart';

/// Entidade que registra uma tentativa do usuário de montar blocos.
///
/// Camada: domain — sem dependências externas.
///
/// Rastreia a sequência escolhida pelo usuário em uma tentativa,
/// o resultado (sucesso/falha) e metadados da tentativa.
class AssemblyAttempt extends Equatable {
  const AssemblyAttempt({
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

  /// Identificador único desta tentativa.
  final String id;

  /// ID do desafio ao qual esta tentativa corresponde.
  final String challengeId;

  /// ID do usuário que fez a tentativa.
  final String userId;

  /// Sequência de IDs de blocos que o usuário selecionou.
  final List<BlockId> selectedBlockSequence;

  /// Indica se a sequência estava correta.
  final bool isCorrect;

  /// Número da tentativa (1, 2, 3, ...).
  final int attemptNumber;

  /// Timestamp de quando a tentativa foi feita.
  final DateTime createdAt;

  /// XP que o usuário ganhou nesta tentativa (0 se incorreta).
  final int xpEarned;

  /// Feedback visual/textual sobre a tentativa.
  final String feedback;

  @override
  List<Object?> get props => [
    id,
    challengeId,
    userId,
    selectedBlockSequence,
    isCorrect,
    attemptNumber,
    createdAt,
    xpEarned,
    feedback,
  ];

  @override
  String toString() =>
      'AssemblyAttempt(id: $id, attempt: $attemptNumber, correct: $isCorrect)';
}
