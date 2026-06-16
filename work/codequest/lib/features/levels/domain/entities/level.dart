import 'package:codequest/features/levels/domain/value_objects/answer_key.dart';

sealed class Level {
  const Level({required this.id});

  final String id;
}

sealed class AnswerableLevel extends Level {
  const AnswerableLevel({
    required super.id,
    required this.question,
    required this.options,
  });

  final String question;
  final Map<AnswerKey, String> options;
}

final class OneChoiceLevel extends AnswerableLevel {
  const OneChoiceLevel({
    required super.id,
    required super.question,
    required super.options,
    required this.correctAnswer,
  });

  final AnswerKey correctAnswer;
}

final class MultiChoiceLevel extends AnswerableLevel {
  const MultiChoiceLevel({
    required super.id,
    required super.question,
    required super.options,
    required this.correctAnswers,
  });

  final Set<AnswerKey> correctAnswers;
}

final class ContentLevel extends Level {
  const ContentLevel({
    required super.id,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}
