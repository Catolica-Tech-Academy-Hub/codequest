import 'package:codequest/features/levels/domain/entities/level.dart';
import 'package:codequest/features/levels/domain/entities/level_result.dart';
import 'package:codequest/features/levels/domain/value_objects/answer_key.dart';

class EvaluateLevelAction {
  const EvaluateLevelAction();

  LevelResult call(AnswerableLevel level, Set<AnswerKey> selected) {
    return switch (level) {
      OneChoiceLevel(:final correctAnswer) => LevelResult(
          correct: selected.length == 1 && selected.single == correctAnswer,
          selected: selected,
          expected: <AnswerKey>{correctAnswer},
        ),
      MultiChoiceLevel(:final correctAnswers) => LevelResult(
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
