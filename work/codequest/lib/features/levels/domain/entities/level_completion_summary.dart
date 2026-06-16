class LevelCompletionSummary {
  const LevelCompletionSummary({
    required this.xpEarned,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.previousStreak,
    required this.currentStreak,
  });

  final int xpEarned;
  final int correctAnswers;
  final int wrongAnswers;
  final int previousStreak;
  final int currentStreak;

  bool get completedWithSuccess => wrongAnswers == 0;

  bool get streakIncreased => currentStreak > previousStreak;
}
