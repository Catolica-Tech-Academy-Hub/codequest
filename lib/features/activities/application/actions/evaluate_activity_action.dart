import 'package:codequest/features/activities/domain/entities/activity.dart';
import 'package:codequest/features/activities/domain/entities/activity_result.dart';
import 'package:codequest/features/activities/domain/value_objects/answer_key.dart';

class EvaluateActivityAction {
  const EvaluateActivityAction();

  ActivityResult call(AnswerableActivity activity, Set<AnswerKey> selected) {
    return switch (activity) {
      OneChoiceActivity(:final correctAnswer) => ActivityResult(
          correct: selected.length == 1 && selected.single == correctAnswer,
          selected: selected,
          expected: <AnswerKey>{correctAnswer},
        ),
      MultiChoiceActivity(:final correctAnswers) => ActivityResult(
          correct: _setEquals(selected, correctAnswers),
          selected: selected,
          expected: correctAnswers,
        ),
    };
  }

  bool _setEquals(Set<AnswerKey> a, Set<AnswerKey> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }
}
