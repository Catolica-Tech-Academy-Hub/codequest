import 'package:codequest/features/block_assembly/domain/entities/assembly_attempt.dart';
import 'package:codequest/features/block_assembly/domain/entities/assembly_challenge.dart';
import 'package:codequest/features/block_assembly/domain/entities/user_challenge_progress.dart';

/// Contrato abstrato para persistência de dados de block assembly.
///
/// Camada: domain — define interface que será implementada pela data layer.
///
/// Segue o padrão repository, invertendo dependência:
/// - Presentation/Application dependem desta abstração
/// - Data implements este contrato
abstract class BlockAssemblyRepositoryContract {
  /// Recupera um desafio específico pelo ID.
  Future<AssemblyChallenge> getChallengeById(String challengeId);

  /// Lista todos os desafios de montagem disponíveis.
  Future<List<AssemblyChallenge>> getAllChallenges();

  /// Registra uma tentativa do usuário.
  Future<void> saveAttempt(AssemblyAttempt attempt);

  /// Recupera o histórico de tentativas de um usuário em um desafio.
  Future<List<AssemblyAttempt>> getAttemptHistory({
    required String userId,
    required String challengeId,
  });

  /// Recupera o progresso do usuário em um desafio específico.
  Future<UserChallengeProgress?> getUserChallengeProgress({
    required String userId,
    required String challengeId,
  });

  /// Atualiza o progresso do usuário após uma tentativa bem-sucedida.
  Future<void> updateUserProgress(UserChallengeProgress progress);

  /// Stream que emite atualizações de progresso em tempo real.
  Stream<UserChallengeProgress> watchUserProgress({
    required String userId,
    required String challengeId,
  });
}
