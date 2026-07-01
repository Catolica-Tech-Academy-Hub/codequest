import 'package:codequest/features/levels/domain/entities/level.dart';
import 'package:codequest/features/levels/domain/entities/level_result.dart';
import 'package:codequest/features/xp/application/actions/award_xp_action.dart';
import 'package:codequest/features/xp/domain/entities/task_kind.dart';
import 'package:codequest/features/xp/domain/entities/task_outcome.dart';
import 'package:codequest/features/xp/domain/entities/xp_attribution.dart';

class XpController {
  XpController({
    required AwardXpAction awardXpAction,
    required String? Function() readUserId,
  })  : _awardXpAction = awardXpAction,
        _readUserId = readUserId;

  final AwardXpAction _awardXpAction;
  final String? Function() _readUserId;

  Future<XpAttribution?> awardForLevel({
    required Level level,
    LevelResult? result,
  }) async {
    final userId = _readUserId();
    if (userId == null || userId.isEmpty) {
      return null;
    }
    if (!_passed(level, result)) {
      return null;
    }

    try {
      return await _awardXpAction(
        userId: userId,
        levelId: level.id,
        outcome: _outcomeFor(level),
      );
    } catch (_) {
      return null;
    }
  }

  bool _passed(Level level, LevelResult? result) {
    return switch (level) {
      ContentLevel() => true,
      AnswerableLevel() => result?.correct ?? false,
    };
  }

  TaskOutcome _outcomeFor(Level level) {
    return switch (level) {
      OneChoiceLevel() => const TaskOutcome(kind: TaskKind.oneChoice),
      MultiChoiceLevel() => const TaskOutcome(kind: TaskKind.multiChoice),
      ContentLevel() => const TaskOutcome(kind: TaskKind.content),
    };
  }
}
