import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/actions/submit_assembly_attempt_use_case.dart';
import '../application/actions/validate_assembly_use_case.dart';
import '../data/repositories/block_assembly_repository.dart';
import '../domain/repositories/block_assembly_repository_contract.dart';

/// Provider para a instância do Firestore.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider para o repositório de block assembly.
final blockAssemblyRepositoryProvider =
    Provider<BlockAssemblyRepositoryContract>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return BlockAssemblyRepository(firestore: firestore);
});

/// Provider para o use case de validação.
final validateAssemblyUseCaseProvider = Provider<ValidateAssemblyUseCase>((ref) {
  final repository = ref.watch(blockAssemblyRepositoryProvider);
  return ValidateAssemblyUseCase(repository);
});

/// Provider para o use case de submissão de tentativa.
final submitAssemblyAttemptUseCaseProvider =
    Provider<SubmitAssemblyAttemptUseCase>((ref) {
  final repository = ref.watch(blockAssemblyRepositoryProvider);
  final validateUseCase = ref.watch(validateAssemblyUseCaseProvider);

  return SubmitAssemblyAttemptUseCase(
    repository: repository,
    validateAssembly: validateUseCase,
  );
});

/// Provider para recuperar um desafio pelo ID (lazy).
final blockAssemblyChallengeProvider =
    FutureProvider.family<dynamic, String>((ref, challengeId) async {
  final repository = ref.watch(blockAssemblyRepositoryProvider);
  return repository.getChallengeById(challengeId);
});

/// Provider para listar todos os desafios.
final blockAssemblyAllChallengesProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(blockAssemblyRepositoryProvider);
  return repository.getAllChallenges();
});

/// Provider para recuperar progresso do usuário em um desafio (lazy).
final userChallengeProgressProvider =
    FutureProvider.family<dynamic, ({String userId, String challengeId})>(
        (ref, params) async {
  final repository = ref.watch(blockAssemblyRepositoryProvider);
  return repository.getUserChallengeProgress(
    userId: params.userId,
    challengeId: params.challengeId,
  );
});

/// Provider para observar progresso em tempo real (lazy).
final watchUserProgressStreamProvider =
    StreamProvider.family<dynamic, ({String userId, String challengeId})>(
        (ref, params) {
  final repository = ref.watch(blockAssemblyRepositoryProvider);
  return repository.watchUserProgress(
    userId: params.userId,
    challengeId: params.challengeId,
  );
});

/// Provider para recuperar histórico de tentativas (lazy).
final attemptHistoryProvider =
    FutureProvider.family<List<dynamic>, ({String userId, String challengeId})>(
        (ref, params) async {
  final repository = ref.watch(blockAssemblyRepositoryProvider);
  return repository.getAttemptHistory(
    userId: params.userId,
    challengeId: params.challengeId,
  );
});
