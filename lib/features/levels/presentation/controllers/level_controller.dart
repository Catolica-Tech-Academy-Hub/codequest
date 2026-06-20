import 'package:codequest/features/levels/application/actions/evaluate_level_action.dart';
import 'package:codequest/features/levels/application/actions/get_level_action.dart';
import 'package:codequest/features/levels/domain/entities/level.dart';
import 'package:codequest/features/levels/domain/entities/level_result.dart';
import 'package:codequest/features/levels/domain/value_objects/answer_key.dart';

class LevelController {
  LevelController({
    required GetLevelAction getAction,
    required EvaluateLevelAction evaluateAction,
  })  : _getAction = getAction,
        _evaluateAction = evaluateAction;

  final GetLevelAction _getAction;
  final EvaluateLevelAction _evaluateAction;

  Future<Level> load(String id) => _getAction.call(id);

  LevelResult evaluate(AnswerableLevel level, Set<AnswerKey> selected) {
    return _evaluateAction.call(level, selected);
  }
}
