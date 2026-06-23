import '../../domain/entities/code_sorting_challenge.dart';
import '../../domain/errors/code_sorting_error.dart';
import '../../domain/value_objects/line_id.dart';

/// Valida se a ordem submetida pelo usuário está correta.
///
/// Camada: application — orquestra regras de negócio.
class ValidateSortingUseCase {
  const ValidateSortingUseCase();

  SortingValidationResult call({
    required CodeSortingChallenge challenge,
    required List<LineId> submittedOrder,
    required int attemptNumber,
  }) {
    if (submittedOrder.isEmpty) {
      return const SortingValidationResult(
        isCorrect: false,
        feedback: 'Nenhuma linha foi ordenada.',
        xpEarned: 0,
        correctCount: 0,
      );
    }

    if (submittedOrder.length != challenge.lines.length) {
      return SortingValidationResult(
        isCorrect: false,
        feedback:
            'Ordem incompleta. Esperado ${challenge.lines.length} linhas.',
        xpEarned: 0,
        correctCount: 0,
      );
    }

    final validIds = challenge.lines.map((l) => l.id.value).toSet();
    for (final lineId in submittedOrder) {
      if (!validIds.contains(lineId.value)) {
        throw InvalidOrderError('Linha inválida: ${lineId.value}');
      }
    }

    // Ordem esperada: linhas ordenadas por expectedPosition
    final expectedOrder = [...challenge.lines]
      ..sort((a, b) => a.expectedPosition.compareTo(b.expectedPosition));
    final expectedIds = expectedOrder.map((l) => l.id.value).toList();

    int correctCount = 0;
    for (int i = 0; i < submittedOrder.length; i++) {
      if (submittedOrder[i].value == expectedIds[i]) correctCount++;
    }

    final isCorrect = correctCount == challenge.lines.length;

    if (isCorrect) {
      final bonus = attemptNumber == 1 ? challenge.xpReward ~/ 5 : 0;
      return SortingValidationResult(
        isCorrect: true,
        feedback: 'Parabéns! Você ordenou o código corretamente!',
        xpEarned: challenge.xpReward + bonus,
        correctCount: correctCount,
      );
    }

    // Encontra a primeira linha errada para feedback útil
    for (int i = 0; i < submittedOrder.length; i++) {
      if (submittedOrder[i].value != expectedIds[i]) {
        return SortingValidationResult(
          isCorrect: false,
          feedback:
              'Linha ${i + 1} incorreta. Verifique a ordem e tente novamente. '
              '($correctCount/${challenge.lines.length} corretas)',
          xpEarned: 0,
          correctCount: correctCount,
        );
      }
    }

    return SortingValidationResult(
      isCorrect: false,
      feedback:
          'Ordem incorreta. $correctCount/${challenge.lines.length} linhas corretas.',
      xpEarned: 0,
      correctCount: correctCount,
    );
  }
}

class SortingValidationResult {
  const SortingValidationResult({
    required this.isCorrect,
    required this.feedback,
    required this.xpEarned,
    required this.correctCount,
  });

  final bool isCorrect;
  final String feedback;
  final int xpEarned;

  /// Quantas linhas estão na posição correta.
  final int correctCount;
}
