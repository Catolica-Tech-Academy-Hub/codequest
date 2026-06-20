import 'package:codequest/features/levels/domain/value_objects/answer_key.dart';

class LevelResult {
  const LevelResult({
    required this.correct,
    required this.selected,
    required this.expected,
  });

  final bool correct;
  final Set<AnswerKey> selected;
  final Set<AnswerKey> expected;
}
