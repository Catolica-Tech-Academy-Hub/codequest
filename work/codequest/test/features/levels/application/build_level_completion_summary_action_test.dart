import 'package:codequest/features/levels/application/actions/build_level_completion_summary_action.dart';
import 'package:codequest/features/levels/domain/entities/level_result.dart';
import 'package:codequest/features/levels/domain/value_objects/answer_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const action = BuildLevelCompletionSummaryAction();

  test('gera resumo de conclusao para resposta correta', () {
    final result = LevelResult(
      correct: true,
      selected: <AnswerKey>{AnswerKey('a')},
      expected: <AnswerKey>{AnswerKey('a')},
    );

    final summary = action.fromResult(result, currentStreak: 2);

    expect(summary.xpEarned, 20);
    expect(summary.correctAnswers, 1);
    expect(summary.wrongAnswers, 0);
    expect(summary.previousStreak, 2);
    expect(summary.currentStreak, 3);
    expect(summary.streakIncreased, isTrue);
  });

  test('gera resumo de conclusao para resposta errada', () {
    final result = LevelResult(
      correct: false,
      selected: <AnswerKey>{AnswerKey('b')},
      expected: <AnswerKey>{AnswerKey('a')},
    );

    final summary = action.fromResult(result, currentStreak: 2);

    expect(summary.xpEarned, 5);
    expect(summary.correctAnswers, 0);
    expect(summary.wrongAnswers, 1);
    expect(summary.previousStreak, 2);
    expect(summary.currentStreak, 0);
    expect(summary.streakIncreased, isFalse);
  });

  test('gera resumo de conclusao para nivel de conteudo', () {
    final summary = action.fromContentLevel(currentStreak: 2);

    expect(summary.xpEarned, 10);
    expect(summary.correctAnswers, 0);
    expect(summary.wrongAnswers, 0);
    expect(summary.previousStreak, 2);
    expect(summary.currentStreak, 3);
  });
}
