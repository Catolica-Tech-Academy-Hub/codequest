import 'package:codequest/features/levels/domain/entities/level.dart';
import 'package:codequest/features/levels/domain/entities/level_type.dart';
import 'package:codequest/features/levels/domain/errors/level_failure.dart';
import 'package:codequest/features/levels/domain/value_objects/answer_key.dart';

class LevelDto {
  const LevelDto({required this.id, required this.raw});

  final String id;
  final Map<String, dynamic> raw;

  Level toDomain() {
    final typeRaw = raw['type'];
    if (typeRaw is! String) {
      throw LevelFailure.malformedLevel('"type" ausente ou inválido em "$id".');
    }
    final type = LevelType.tryParse(typeRaw);
    if (type == null) {
      throw LevelFailure.unknownType(typeRaw);
    }

    return switch (type) {
      LevelType.oneChoice => _buildOneChoice(),
      LevelType.multiChoice => _buildMultiChoice(),
      LevelType.content => _buildContent(),
    };
  }

  Map<AnswerKey, String> _parseAnswers() {
    final answersRaw = raw['answers'];
    if (answersRaw is! Map || answersRaw.isEmpty) {
      throw LevelFailure.malformedLevel('"answers" ausente ou vazio em "$id".');
    }
    final options = <AnswerKey, String>{};
    answersRaw.forEach((key, value) {
      if (key is! String || value is! String) {
        throw LevelFailure.malformedLevel(
          'entrada inválida em "answers" de "$id".',
        );
      }
      options[AnswerKey(key)] = value;
    });
    return options;
  }

  String _parseQuestion() {
    final question = raw['question'];
    if (question is! String || question.isEmpty) {
      throw LevelFailure.malformedLevel('"question" ausente ou vazia em "$id".');
    }
    return question;
  }

  OneChoiceLevel _buildOneChoice() {
    final question = _parseQuestion();
    final options = _parseAnswers();
    final correctRaw = raw['correct_answer'];
    if (correctRaw is! String) {
      throw LevelFailure.malformedLevel('"correct_answer" ausente em "$id".');
    }
    final correct = AnswerKey(correctRaw);
    if (!options.containsKey(correct)) {
      throw LevelFailure.malformedLevel(
        '"correct_answer" ("$correctRaw") não está em "answers" de "$id".',
      );
    }
    return OneChoiceLevel(
      id: id,
      question: question,
      options: options,
      correctAnswer: correct,
    );
  }

  MultiChoiceLevel _buildMultiChoice() {
    final question = _parseQuestion();
    final options = _parseAnswers();
    final correctRaw = raw['correct_answers'];
    if (correctRaw is! List || correctRaw.isEmpty) {
      throw LevelFailure.malformedLevel(
        '"correct_answers" ausente ou vazio em "$id".',
      );
    }
    final correct = <AnswerKey>{};
    for (final item in correctRaw) {
      if (item is! String) {
        throw LevelFailure.malformedLevel(
          'entrada inválida em "correct_answers" de "$id".',
        );
      }
      final key = AnswerKey(item);
      if (!options.containsKey(key)) {
        throw LevelFailure.malformedLevel(
          '"correct_answers" referencia chave inexistente ("$item") em "$id".',
        );
      }
      correct.add(key);
    }
    return MultiChoiceLevel(
      id: id,
      question: question,
      options: options,
      correctAnswers: correct,
    );
  }

  ContentLevel _buildContent() {
    final title = raw['title'];
    if (title is! String || title.isEmpty) {
      throw LevelFailure.malformedLevel('"title" ausente ou vazio em "$id".');
    }
    final body = raw['body'];
    if (body is! String || body.isEmpty) {
      throw LevelFailure.malformedLevel('"body" ausente ou vazio em "$id".');
    }
    return ContentLevel(id: id, title: title, body: body);
  }
}
