import 'package:codequest/features/activities/application/actions/evaluate_activity_action.dart';
import 'package:codequest/features/activities/application/actions/get_activity_action.dart';
import 'package:codequest/features/activities/domain/entities/activity.dart';
import 'package:codequest/features/activities/domain/entities/activity_result.dart';
import 'package:codequest/features/activities/domain/value_objects/answer_key.dart';

class ActivityController {
  ActivityController({
    required GetActivityAction getAction,
    required EvaluateActivityAction evaluateAction,
  })  : _getAction = getAction,
        _evaluateAction = evaluateAction;

  final GetActivityAction _getAction;
  final EvaluateActivityAction _evaluateAction;

  Future<Activity> load(String id) => _getAction.call(id);

  ActivityResult evaluate(AnswerableActivity activity, Set<AnswerKey> selected) {
    return _evaluateAction.call(activity, selected);
  }
}
