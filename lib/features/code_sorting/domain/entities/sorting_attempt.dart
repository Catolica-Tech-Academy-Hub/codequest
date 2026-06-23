import 'package:equatable/equatable.dart';

import '../value_objects/line_id.dart';

/// Representa uma tentativa de ordenação feita pelo usuário.
///
/// Camada: domain — sem dependências externas.
class SortingAttempt extends Equatable {
  const SortingAttempt({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.submittedOrder,
    required this.isCorrect,
    required this.attemptNumber,
    required this.createdAt,
    required this.xpEarned,
    required this.feedback,
  });

  final String id;
  final String challengeId;
  final String userId;

  /// Ordem submetida pelo usuário (lista de IDs de linhas).
  final List<LineId> submittedOrder;

  final bool isCorrect;
  final int attemptNumber;
  final DateTime createdAt;
  final int xpEarned;
  final String feedback;

  @override
  List<Object?> get props => [
        id,
        challengeId,
        userId,
        submittedOrder,
        isCorrect,
        attemptNumber,
        createdAt,
        xpEarned,
        feedback,
      ];
}
