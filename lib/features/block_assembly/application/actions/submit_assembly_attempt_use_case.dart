import 'package:uuid/uuid.dart';

import '../../domain/entities/assembly_attempt.dart';
import '../../domain/entities/assembly_challenge.dart';
import '../../domain/entities/user_challenge_progress.dart';
import '../../domain/errors/block_assembly_error.dart';
import '../../domain/repositories/block_assembly_repository_contract.dart';
import '../../domain/value_objects/block_id.dart';
import 'validate_assembly_use_case.dart';

/// Use case que orquestra uma tentativa completa de resolver um desafio.
///
/// Camada: application — coordena entre repositório, validação e persistência.
///
/// Fluxo:
/// 1. Valida sequência usando [ValidateAssemblyUseCase]
/// 2. Salva a tentativa no repositório
/// 3. Atualiza progresso do usuário
/// 4. Retorna resultado com feedback
class SubmitAssemblyAttemptUseCase {
  SubmitAssemblyAttemptUseCase({
    required BlockAssemblyRepositoryContract repository,
    required ValidateAssemblyUseCase validateAssembly,
  })  : _repository = repository,
        _validateAssembly = validateAssembly;

  final BlockAssemblyRepositoryContract _repository;
  final ValidateAssemblyUseCase _validateAssembly;
  static const _uuid = Uuid();

  /// Submete uma tentativa de montar blocos.
  ///
  /// Lança [MaxAttemptsExceededError] se o usuário excedeu tentativas.
  /// Retorna [AssemblyAttemptResult] com o resultado e progresso atualizado.
  Future<AssemblyAttemptResult> call({
    required AssemblyChallenge challenge,
    required String userId,
    required List<BlockId> selectedSequence,
  }) async {
    // 1. Recuperar progresso atual
    var progress = await _repository.getUserChallengeProgress(
      userId: userId,
      challengeId: challenge.id,
    );

    progress ??= UserChallengeProgress(
      userId: userId,
      challengeId: challenge.id,
      isCompleted: false,
      attemptCount: 0,
      totalXpEarned: 0,
    );

    // 2. Verificar se ainda há tentativas disponíveis
    if (progress.isCompleted) {
      return AssemblyAttemptResult(
        isSuccess: true,
        isAlreadyCompleted: true,
        feedback: 'Você já completou este desafio! ✅',
        xpEarned: 0,
        newProgress: progress,
      );
    }

    if (progress.attemptCount >= challenge.maxAttempts) {
      throw MaxAttemptsExceededError(
        'Você excedeu o número máximo de ${challenge.maxAttempts} tentativas.',
      );
    }

    // 3. Validar sequência
    final validationResult = await _validateAssembly.call(
      challenge: challenge,
      userSequence: selectedSequence,
      attemptNumber: progress.attemptCount + 1,
    );

    // 4. Criar e salvar tentativa
    final attemptId = _uuid.v4();
    final attempt = AssemblyAttempt(
      id: attemptId,
      challengeId: challenge.id,
      userId: userId,
      selectedBlockSequence: selectedSequence,
      isCorrect: validationResult.isCorrect,
      attemptNumber: progress.attemptCount + 1,
      createdAt: DateTime.now(),
      xpEarned: validationResult.xpEarned,
      feedback: validationResult.feedback,
    );

    await _repository.saveAttempt(attempt);

    // 5. Atualizar progresso do usuário
    final newProgress = UserChallengeProgress(
      userId: userId,
      challengeId: challenge.id,
      isCompleted: validationResult.isCorrect || progress.isCompleted,
      attemptCount: progress.attemptCount + 1,
      totalXpEarned: progress.totalXpEarned + validationResult.xpEarned,
      lastAttemptAt: DateTime.now(),
      firstCompletedAt: validationResult.isCorrect
          ? (progress.firstCompletedAt ?? DateTime.now())
          : progress.firstCompletedAt,
    );

    await _repository.updateUserProgress(newProgress);

    return AssemblyAttemptResult(
      isSuccess: validationResult.isCorrect,
      isAlreadyCompleted: false,
      feedback: validationResult.feedback,
      xpEarned: validationResult.xpEarned,
      newProgress: newProgress,
      attempt: attempt,
    );
  }
}

/// Resultado de uma tentativa submetida.
class AssemblyAttemptResult {
  const AssemblyAttemptResult({
    required this.isSuccess,
    required this.isAlreadyCompleted,
    required this.feedback,
    required this.xpEarned,
    required this.newProgress,
    this.attempt,
  });

  /// Se a tentativa foi bem-sucedida (sequência correta).
  final bool isSuccess;

  /// Se o usuário já tinha completado este desafio.
  final bool isAlreadyCompleted;

  /// Feedback para o usuário.
  final String feedback;

  /// XP ganho nesta tentativa.
  final int xpEarned;

  /// Progresso atualizado do usuário.
  final UserChallengeProgress newProgress;

  /// A tentativa registrada (null se já completado).
  final AssemblyAttempt? attempt;
}
