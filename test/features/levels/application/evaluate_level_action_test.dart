import 'package:codequest/features/levels/application/actions/evaluate_level_action.dart';
import 'package:codequest/features/levels/domain/entities/level.dart';
import 'package:codequest/features/levels/domain/value_objects/answer_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const action = EvaluateLevelAction();

  group('one-choice', () {
    final level = OneChoiceLevel(
      id: 'q1',
      question: 'Q?',
      options: <AnswerKey, String>{
        AnswerKey('a'): 'A',
        AnswerKey('b'): 'B',
      },
      correctAnswer: AnswerKey('b'),
    );

    test('correta quando seleciona a chave certa', () {
      final result = action.call(level, <AnswerKey>{AnswerKey('b')});
      expect(result.correct, isTrue);
      expect(result.expected, <AnswerKey>{AnswerKey('b')});
    });

    test('incorreta quando seleciona outra', () {
      final result = action.call(level, <AnswerKey>{AnswerKey('a')});
      expect(result.correct, isFalse);
    });

    test('incorreta quando seleciona vazio', () {
      final result = action.call(level, <AnswerKey>{});
      expect(result.correct, isFalse);
    });

    test('incorreta quando seleciona mais de uma', () {
      final result = action.call(
        level,
        <AnswerKey>{AnswerKey('a'), AnswerKey('b')},
      );
      expect(result.correct, isFalse);
    });
  });

  group('multi-choice', () {
    final level = MultiChoiceLevel(
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
        level,
        <AnswerKey>{AnswerKey('a'), AnswerKey('c')},
      );
      expect(result.correct, isTrue);
    });

    test('correta independente da ordem (Set)', () {
      final result = action.call(
        level,
        <AnswerKey>{AnswerKey('c'), AnswerKey('a')},
      );
      expect(result.correct, isTrue);
    });

    test('incorreta com seleção parcial', () {
      final result = action.call(level, <AnswerKey>{AnswerKey('a')});
      expect(result.correct, isFalse);
    });

    test('incorreta com seleção excedente', () {
      final result = action.call(
        level,
        <AnswerKey>{AnswerKey('a'), AnswerKey('b'), AnswerKey('c')},
      );
      expect(result.correct, isFalse);
    });

    test('incorreta com seleção vazia', () {
      final result = action.call(level, <AnswerKey>{});
      expect(result.correct, isFalse);
    });
  });
}
