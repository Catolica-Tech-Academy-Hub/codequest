import 'package:codequest/features/activities/application/actions/evaluate_activity_action.dart';
import 'package:codequest/features/activities/domain/entities/activity.dart';
import 'package:codequest/features/activities/domain/value_objects/answer_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const action = EvaluateActivityAction();

  group('one-choice', () {
    final activity = OneChoiceActivity(
      id: 'q1',
      question: 'Q?',
      options: <AnswerKey, String>{
        AnswerKey('a'): 'A',
        AnswerKey('b'): 'B',
      },
      correctAnswer: AnswerKey('b'),
    );

    test('correta quando seleciona a chave certa', () {
      final result = action.call(activity, <AnswerKey>{AnswerKey('b')});
      expect(result.correct, isTrue);
      expect(result.expected, <AnswerKey>{AnswerKey('b')});
    });

    test('incorreta quando seleciona outra', () {
      final result = action.call(activity, <AnswerKey>{AnswerKey('a')});
      expect(result.correct, isFalse);
    });

    test('incorreta quando seleciona vazio', () {
      final result = action.call(activity, <AnswerKey>{});
      expect(result.correct, isFalse);
    });

    test('incorreta quando seleciona mais de uma', () {
      final result = action.call(
        activity,
        <AnswerKey>{AnswerKey('a'), AnswerKey('b')},
      );
      expect(result.correct, isFalse);
    });
  });

  group('multi-choice', () {
    final activity = MultiChoiceActivity(
      id: 'q2',
      question: 'Q?',
      options: <AnswerKey, String>{
        AnswerKey('a'): 'A',
        AnswerKey('b'): 'B',
        AnswerKey('c'): 'C',
        AnswerKey('d'): 'D',
      },
      correctAnswers: <AnswerKey>{AnswerKey('a'), AnswerKey('c')},
    );

    test('correta quando seleciona o conjunto exato', () {
      final result = action.call(
        activity,
        <AnswerKey>{AnswerKey('a'), AnswerKey('c')},
      );
      expect(result.correct, isTrue);
    });

    test('correta independente da ordem (Set)', () {
      final result = action.call(
        activity,
        <AnswerKey>{AnswerKey('c'), AnswerKey('a')},
      );
      expect(result.correct, isTrue);
    });

    test('incorreta com seleção parcial', () {
      final result = action.call(activity, <AnswerKey>{AnswerKey('a')});
      expect(result.correct, isFalse);
    });

    test('incorreta com seleção excedente', () {
      final result = action.call(
        activity,
        <AnswerKey>{AnswerKey('a'), AnswerKey('b'), AnswerKey('c')},
      );
      expect(result.correct, isFalse);
    });

    test('incorreta com seleção vazia', () {
      final result = action.call(activity, <AnswerKey>{});
      expect(result.correct, isFalse);
    });
  });
}
