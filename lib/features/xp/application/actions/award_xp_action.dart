import 'package:codequest/features/xp/domain/entities/task_outcome.dart';
import 'package:codequest/features/xp/domain/entities/xp_attribution.dart';
import 'package:codequest/features/xp/domain/repositories/xp_repository_contract.dart';
import 'package:codequest/features/xp/domain/services/xp_calculator.dart';

class AwardXpAction {
  AwardXpAction({
    required XpRepositoryContract repository,
    XpCalculator calculator = const XpCalculator(),
    DateTime Function() clock = DateTime.now,
  })  : _repository = repository,
        _calculator = calculator,
        _clock = clock;

  final XpRepositoryContract _repository;
  final XpCalculator _calculator;
  final DateTime Function() _clock;

  Future<XpAttribution> call({
    required String userId,
    required String levelId,
    required TaskOutcome outcome,
  }) async {
    final state = await _repository.fetchState(userId);
    final grant = _calculator.calculate(
      state: state,
      outcome: outcome,
      now: _clock(),
    );
    final awarded = await _repository.commitLevelCompletion(
      userId: userId,
      levelId: levelId,
      grant: grant,
    );
    return awarded
        ? XpAttribution.awarded(grant)
        : const XpAttribution.skipped();
  }
}
