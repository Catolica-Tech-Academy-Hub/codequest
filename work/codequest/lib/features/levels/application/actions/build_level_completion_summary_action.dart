import 'package:codequest/features/levels/domain/entities/level_completion_summary.dart';
import 'package:codequest/features/levels/domain/entities/level_result.dart';

class BuildLevelCompletionSummaryAction {
  const BuildLevelCompletionSummaryAction();

  static const int correctAnswerXp = 20;
  static const int wrongAnswerXp = 5;
  static const int contentLevelXp = 10;

  LevelCompletionSummary fromResult(
    LevelResult result, {
    int currentStreak = 0,
  }) {
    final isCorrect = result.correct;
    return LevelCompletionSummary(
      xpEarned: isCorrect ? correctAnswerXp : wrongAnswerXp,
      correctAnswers: isCorrect ? 1 : 0,
      wrongAnswers: isCorrect ? 0 : 1,
      previousStreak: currentStreak,
      currentStreak: isCorrect ? currentStreak + 1 : 0,
    );
  }

  LevelCompletionSummary fromContentLevel({
    int currentStreak = 0,
  }) {
    return LevelCompletionSummary(
      xpEarned: contentLevelXp,
      correctAnswers: 0,
      wrongAnswers: 0,
      previousStreak: currentStreak,
      currentStreak: currentStreak + 1,
    );
  }
}
