import 'package:codequest/features/activities/domain/entities/activity.dart';
import 'package:codequest/features/activities/domain/entities/activity_type.dart';
import 'package:codequest/features/activities/domain/errors/activity_failure.dart';
import 'package:codequest/features/activities/domain/value_objects/answer_key.dart';

class ActivityDto {
  const ActivityDto({required this.id, required this.raw});

  final String id;
  final Map<String, dynamic> raw;

  Activity toDomain() {
    final typeRaw = raw['type'];
    if (typeRaw is! String) {
      throw ActivityFailure.malformedActivity('"type" ausente ou inválido em "$id".');
    }
    final type = ActivityType.tryParse(typeRaw);
    if (type == null) {
      throw ActivityFailure.unknownType(typeRaw);
    }

    return switch (type) {
      ActivityType.oneChoice => _buildOneChoice(),
      ActivityType.multiChoice => _buildMultiChoice(),
      ActivityType.content => _buildContent(),
    };
  }

  Map<AnswerKey, String> _parseAnswers() {
    final answersRaw = raw['answers'];
    if (answersRaw is! Map || answersRaw.isEmpty) {
      throw ActivityFailure.malformedActivity('"answers" ausente ou vazio em "$id".');
    }
    final options = <AnswerKey, String>{};
    answersRaw.forEach((key, value) {
      if (key is! String || value is! String) {
        throw ActivityFailure.malformedActivity(
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
      throw ActivityFailure.malformedActivity('"question" ausente ou vazia em "$id".');
    }
    return question;
  }

  OneChoiceActivity _buildOneChoice() {
    final question = _parseQuestion();
    final options = _parseAnswers();
    final correctRaw = raw['correct_answer'];
    if (correctRaw is! String) {
      throw ActivityFailure.malformedActivity('"correct_answer" ausente em "$id".');
    }
    final correct = AnswerKey(correctRaw);
    if (!options.containsKey(correct)) {
      throw ActivityFailure.malformedActivity(
        '"correct_answer" ("$correctRaw") não está em "answers" de "$id".',
      );
    }
    return OneChoiceActivity(
      id: id,
      question: question,
      options: options,
      correctAnswer: correct,
    );
  }

  MultiChoiceActivity _buildMultiChoice() {
    final question = _parseQuestion();
    final options = _parseAnswers();
    final correctRaw = raw['correct_answers'];
    if (correctRaw is! List || correctRaw.isEmpty) {
      throw ActivityFailure.malformedActivity(
        '"correct_answers" ausente ou vazio em "$id".',
      );
    }
    final correct = <AnswerKey>{};
    for (final item in correctRaw) {
      if (item is! String) {
        throw ActivityFailure.malformedActivity(
          'entrada inválida em "correct_answers" de "$id".',
        );
      }
      final key = AnswerKey(item);
      if (!options.containsKey(key)) {
        throw ActivityFailure.malformedActivity(
          '"correct_answers" referencia chave inexistente ("$item") em "$id".',
        );
      }
      correct.add(key);
    }
    return MultiChoiceActivity(
      id: id,
      question: question,
      options: options,
      correctAnswers: correct,
    );
  }

  ContentActivity _buildContent() {
    final title = raw['title'];
    if (title is! String || title.isEmpty) {
      throw ActivityFailure.malformedActivity('"title" ausente ou vazio em "$id".');
    }
    final body = raw['body'];
    if (body is! String || body.isEmpty) {
      throw ActivityFailure.malformedActivity('"body" ausente ou vazio em "$id".');
    }
    return ContentActivity(id: id, title: title, body: body);
  }
}
