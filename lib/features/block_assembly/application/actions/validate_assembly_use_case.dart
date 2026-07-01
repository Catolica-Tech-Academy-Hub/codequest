import 'package:codequest/features/block_assembly/domain/entities/assembly_challenge.dart';
import 'package:codequest/features/block_assembly/domain/errors/block_assembly_error.dart';
import 'package:codequest/features/block_assembly/domain/repositories/block_assembly_repository_contract.dart';
import 'package:codequest/features/block_assembly/domain/value_objects/block_id.dart';

/// Use case que valida se uma sequência de blocos está correta e gera feedback.
///
/// Camada: application — orquestra regras de negócio usando contratos.
///
/// Responsabilidades:
/// 1. Comparar sequência do usuário com sequência esperada
/// 2. Gerar feedback detalhado (qual bloco está errado, em qual posição)
/// 3. Calcular XP ganho baseado na tentativa
class ValidateAssemblyUseCase {
  ValidateAssemblyUseCase(this._repository);

  final BlockAssemblyRepositoryContract _repository;

  /// Valida a sequência montada pelo usuário e retorna resultado.
  ///
  /// Lança [InvalidSequenceError] se algum bloco não existe no desafio.
  /// Retorna [AssemblyValidationResult] com isCorrect, feedback e xpEarned.
  Future<AssemblyValidationResult> call({
    required AssemblyChallenge challenge,
    required List<BlockId> userSequence,
    required int attemptNumber,
  }) async {
    // Validação básica
    if (userSequence.isEmpty) {
      return AssemblyValidationResult(
        isCorrect: false,
        feedback: 'Você não selecionou nenhum bloco.',
        xpEarned: 0,
      );
    }

    if (userSequence.length != challenge.blocks.length) {
      return AssemblyValidationResult(
        isCorrect: false,
        feedback:
            'Sequência incompleta. Esperado ${challenge.blocks.length} blocos, recebido ${userSequence.length}.',
        xpEarned: 0,
      );
    }

    // Validar que todos os blocos existem no desafio
    final validBlockIds = challenge.blocks.map((b) => b.id.value).toSet();
    for (final blockId in userSequence) {
      if (!validBlockIds.contains(blockId.value)) {
        throw InvalidSequenceError(
          'Bloco inválido: ${blockId.value}',
        );
      }
    }

    // Comparar com sequência esperada
    final expectedSequence = challenge.blocks
        .map((b) => b.id)
        .toList();

    final isCorrect = _isSequenceCorrect(userSequence, expectedSequence);

    if (isCorrect) {
      // Cálculo de XP: bonus por fazer correto na primeira tentativa
      final xpBonus = attemptNumber == 1 ? challenge.xpReward ~/ 5 : 0;
      final totalXp = challenge.xpReward + xpBonus;

      return AssemblyValidationResult(
        isCorrect: true,
        feedback: '🎉 Parabéns! Você montou a sequência corretamente!',
        xpEarned: totalXp,
      );
    }

    // Gerar feedback para sequência incorreta
    final feedback = _generateIncorrectFeedback(
      userSequence,
      expectedSequence,
      challenge,
    );

    return AssemblyValidationResult(
      isCorrect: false,
      feedback: feedback,
      xpEarned: 0,
    );
  }

  /// Verifica se a sequência do usuário está exatamente correta.
  bool _isSequenceCorrect(
    List<BlockId> userSeq,
    List<BlockId> expectedSeq,
  ) {
    if (userSeq.length != expectedSeq.length) return false;
    for (int i = 0; i < userSeq.length; i++) {
      if (userSeq[i].value != expectedSeq[i].value) return false;
    }
    return true;
  }

  /// Gera feedback útil indicando qual bloco está errado.
  String _generateIncorrectFeedback(
    List<BlockId> userSeq,
    List<BlockId> expectedSeq,
    AssemblyChallenge challenge,
  ) {
    // Encontra o primeiro bloco incorreto
    for (int i = 0; i < userSeq.length; i++) {
      if (userSeq[i].value != expectedSeq[i].value) {
        final wrongBlock = challenge.blocks
            .firstWhere((b) => b.id.value == userSeq[i].value);
        final correctBlock = challenge.blocks
            .firstWhere((b) => b.id.value == expectedSeq[i].value);

        return 'Bloco incorreto na posição ${i + 1}. '
            'Você colocou "${wrongBlock.label.value}", '
            'mas deveria ser "${correctBlock.label.value}".';
      }
    }

    return 'Sequência incorreta. Tente novamente!';
  }
}

/// Resultado da validação de uma tentativa.
class AssemblyValidationResult {
  const AssemblyValidationResult({
    required this.isCorrect,
    required this.feedback,
    required this.xpEarned,
  });

  /// Se a sequência estava correta.
  final bool isCorrect;

  /// Feedback visual/textual para o usuário.
  final String feedback;

  /// XP ganho nesta tentativa (0 se incorreta).
  final int xpEarned;
}
