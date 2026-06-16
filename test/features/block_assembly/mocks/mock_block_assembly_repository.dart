import 'package:codequest/features/block_assembly/domain/entities/assembly_attempt.dart';
import 'package:codequest/features/block_assembly/domain/entities/assembly_challenge.dart';
import 'package:codequest/features/block_assembly/domain/entities/user_challenge_progress.dart';
import 'package:codequest/features/block_assembly/domain/repositories/block_assembly_repository_contract.dart';

/// Mock do repositório para testes
class MockBlockAssemblyRepository implements BlockAssemblyRepositoryContract {
  final Map<String, AssemblyChallenge> _challenges = {};
  final Map<String, List<AssemblyAttempt>> _attempts = {};
  final Map<String, UserChallengeProgress> _progress = {};
  final Map<String, UserChallengeProgress> _progressStream = {};

  @override
  Future<AssemblyChallenge> getChallengeById(String challengeId) async {
    if (_challenges.containsKey(challengeId)) {
      return _challenges[challengeId]!;
    }
    throw Exception('Desafio não encontrado: $challengeId');
  }

  @override
  Future<List<AssemblyChallenge>> getAllChallenges() async {
    return _challenges.values.toList();
  }

  @override
  Future<void> saveAttempt(AssemblyAttempt attempt) async {
    final key = '${attempt.userId}_${attempt.challengeId}';
    if (!_attempts.containsKey(key)) {
      _attempts[key] = [];
    }
    _attempts[key]!.add(attempt);
  }

  @override
  Future<List<AssemblyAttempt>> getAttemptHistory({
    required String userId,
    required String challengeId,
  }) async {
    final key = '${userId}_${challengeId}';
    return _attempts[key] ?? [];
  }

  @override
  Future<UserChallengeProgress?> getUserChallengeProgress({
    required String userId,
    required String challengeId,
  }) async {
    final key = '${userId}_${challengeId}';
    return _progress[key];
  }

  @override
  Future<void> updateUserProgress(UserChallengeProgress progress) async {
    final key = '${progress.userId}_${progress.challengeId}';
    _progress[key] = progress;
  }

  @override
  Stream<UserChallengeProgress> watchUserProgress({
    required String userId,
    required String challengeId,
  }) {
    final key = '${userId}_${challengeId}';
    final progress = _progressStream[key];
    if (progress != null) {
      return Stream.value(progress);
    }
    return Stream.error(Exception('Progresso não encontrado'));
  }

  // Helpers para testes
  void addChallenge(AssemblyChallenge challenge) {
    _challenges[challenge.id] = challenge;
  }

  void addProgress(UserChallengeProgress progress) {
    final key = '${progress.userId}_${progress.challengeId}';
    _progress[key] = progress;
  }

  void reset() {
    _challenges.clear();
    _attempts.clear();
    _progress.clear();
    _progressStream.clear();
  }
}
