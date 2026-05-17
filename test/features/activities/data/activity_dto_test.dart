import 'package:codequest/features/activities/data/dtos/activity_dto.dart';
import 'package:codequest/features/activities/domain/entities/activity.dart';
import 'package:codequest/features/activities/domain/errors/activity_failure.dart';
import 'package:codequest/features/activities/domain/value_objects/answer_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActivityDto.toDomain (one-choice)', () {
    test('mapeia JSON válido para OneChoiceActivity', () {
      final dto = ActivityDto(
        id: 'q1',
        raw: <String, dynamic>{
          'type': 'one-choice',
          'question': 'Qual?',
          'answers': <String, dynamic>{'a': 'A', 'b': 'B'},
          'correct_answer': 'b',
        },
      );
      final domain = dto.toDomain();
      expect(domain, isA<OneChoiceActivity>());
      domain as OneChoiceActivity;
      expect(domain.id, 'q1');
      expect(domain.correctAnswer, AnswerKey('b'));
      expect(domain.options.length, 2);
    });

    test('falha se correct_answer não está em answers', () {
      final dto = ActivityDto(
        id: 'q1',
        raw: <String, dynamic>{
          'type': 'one-choice',
          'question': 'Qual?',
          'answers': <String, dynamic>{'a': 'A'},
          'correct_answer': 'b',
        },
      );
      expect(dto.toDomain, throwsA(isA<MalformedActivityFailure>()));
    });
  });

  group('ActivityDto.toDomain (multi-choice)', () {
    test('mapeia JSON válido para MultiChoiceActivity', () {
      final dto = ActivityDto(
        id: 'q2',
        raw: <String, dynamic>{
          'type': 'multi-choice',
          'question': 'Quais?',
          'answers': <String, dynamic>{'a': 'A', 'b': 'B', 'c': 'C'},
          'correct_answers': <dynamic>['a', 'c'],
        },
      );
      final domain = dto.toDomain();
      expect(domain, isA<MultiChoiceActivity>());
      domain as MultiChoiceActivity;
      expect(domain.correctAnswers, <AnswerKey>{AnswerKey('a'), AnswerKey('c')});
    });

    test('falha se correct_answers referencia chave inexistente', () {
      final dto = ActivityDto(
        id: 'q2',
        raw: <String, dynamic>{
          'type': 'multi-choice',
          'question': 'Quais?',
          'answers': <String, dynamic>{'a': 'A', 'b': 'B'},
          'correct_answers': <dynamic>['a', 'z'],
        },
      );
      expect(dto.toDomain, throwsA(isA<MalformedActivityFailure>()));
    });

    test('falha se correct_answers vazio', () {
      final dto = ActivityDto(
        id: 'q2',
        raw: <String, dynamic>{
          'type': 'multi-choice',
          'question': 'Quais?',
          'answers': <String, dynamic>{'a': 'A'},
          'correct_answers': <dynamic>[],
        },
      );
      expect(dto.toDomain, throwsA(isA<MalformedActivityFailure>()));
    });
  });

  group('ActivityDto.toDomain (erros gerais)', () {
    test('falha em type desconhecido', () {
      final dto = ActivityDto(
        id: 'q',
        raw: <String, dynamic>{
          'type': 'ordering',
          'question': 'Q',
          'answers': <String, dynamic>{'a': 'A'},
          'correct_answer': 'a',
        },
      );
      expect(dto.toDomain, throwsA(isA<UnknownActivityTypeFailure>()));
    });

    test('falha em question ausente', () {
      final dto = ActivityDto(
        id: 'q',
        raw: <String, dynamic>{
          'type': 'one-choice',
          'answers': <String, dynamic>{'a': 'A'},
          'correct_answer': 'a',
        },
      );
      expect(dto.toDomain, throwsA(isA<MalformedActivityFailure>()));
    });

    test('falha em answers vazio', () {
      final dto = ActivityDto(
        id: 'q',
        raw: <String, dynamic>{
          'type': 'one-choice',
          'question': 'Q',
          'answers': <String, dynamic>{},
          'correct_answer': 'a',
        },
      );
      expect(dto.toDomain, throwsA(isA<MalformedActivityFailure>()));
    });

    test('falha em chave de answer inválida', () {
      final dto = ActivityDto(
        id: 'q',
        raw: <String, dynamic>{
          'type': 'one-choice',
          'question': 'Q',
          'answers': <String, dynamic>{'A': 'A'},
          'correct_answer': 'A',
        },
      );
      expect(dto.toDomain, throwsA(isA<InvalidAnswerKeyFailure>()));
    });
  });
}
