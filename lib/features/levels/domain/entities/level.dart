import 'package:codequest/features/levels/domain/value_objects/answer_key.dart';

sealed class Level {
  const Level({required this.id});

  final String id;
}

/// Explicação rápida (Teoria) exibida em um pop-up antes do exercício.
///
/// É opcional: exercícios sem teoria simplesmente não exibem o pop-up.
final class LevelTheory {
  const LevelTheory({required this.title, required this.body});

  final String title;
  final String body;
}

sealed class AnswerableLevel extends Level {
  const AnswerableLevel({
    required super.id,
    required this.question,
    required this.options,
    this.theory,
  });

  final String question;
  final Map<AnswerKey, String> options;

  /// Teoria opcional exibida antes do exercício (RF05). `null` quando ausente.
  final LevelTheory? theory;
}

final class OneChoiceLevel extends AnswerableLevel {
  const OneChoiceLevel({
    required super.id,
    required super.question,
    required super.options,
    required this.correctAnswer,
    super.theory,
  });

  final AnswerKey correctAnswer;
}

final class MultiChoiceLevel extends AnswerableLevel {
  const MultiChoiceLevel({
    required super.id,
    required super.question,
    required super.options,
    required this.correctAnswers,
    super.theory,
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
