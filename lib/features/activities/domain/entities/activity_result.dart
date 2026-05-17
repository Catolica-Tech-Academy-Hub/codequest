import 'package:codequest/features/activities/domain/value_objects/answer_key.dart';

class ActivityResult {
  const ActivityResult({
    required this.correct,
    required this.selected,
    required this.expected,
  });

  final bool correct;
  final Set<AnswerKey> selected;
  final Set<AnswerKey> expected;
}
