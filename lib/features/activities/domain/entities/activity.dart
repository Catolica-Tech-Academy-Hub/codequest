import 'package:codequest/features/activities/domain/value_objects/answer_key.dart';

sealed class Activity {
  const Activity({required this.id});

  final String id;
}

sealed class AnswerableActivity extends Activity {
  const AnswerableActivity({
    required super.id,
    required this.question,
    required this.options,
  });

  final String question;
  final Map<AnswerKey, String> options;
}

final class OneChoiceActivity extends AnswerableActivity {
  const OneChoiceActivity({
    required super.id,
    required super.question,
    required super.options,
    required this.correctAnswer,
  });

  final AnswerKey correctAnswer;
}

final class MultiChoiceActivity extends AnswerableActivity {
  const MultiChoiceActivity({
    required super.id,
    required super.question,
    required super.options,
    required this.correctAnswers,
  });

  final Set<AnswerKey> correctAnswers;
}

final class ContentActivity extends Activity {
  const ContentActivity({
    required super.id,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}
