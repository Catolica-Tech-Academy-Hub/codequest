import 'package:codequest/features/streak/domain/streak_info.dart';

/// Responsável por calcular a sequência de dias consecutivos de uso.
///
/// Regra:
/// - Se o usuário nunca praticou, começa com streak 1.
/// - Se já praticou hoje, mantém a streak atual.
/// - Se praticou ontem, soma +1.
/// - Se ficou um ou mais dias sem praticar, reinicia para 1.
class StreakCalculator {
  StreakInfo updateStreak({
    required DateTime today,
    required DateTime? lastActiveDate,
    required int currentStreak,
    required int bestStreak,
  }) {
    final todayDate = DateTime(today.year, today.month, today.day);

    if (lastActiveDate == null) {
      return StreakInfo(
        currentStreak: 1,
        bestStreak: 1,
        lastActiveDate: todayDate,
      );
    }

    final lastDate = DateTime(
      lastActiveDate.year,
      lastActiveDate.month,
      lastActiveDate.day,
    );

    final difference = todayDate.difference(lastDate).inDays;

    if (difference == 0) {
      return StreakInfo(
        currentStreak: currentStreak,
        bestStreak: bestStreak,
        lastActiveDate: lastDate,
      );
    }

    if (difference == 1) {
      final newStreak = currentStreak + 1;

      return StreakInfo(
        currentStreak: newStreak,
        bestStreak: newStreak > bestStreak ? newStreak : bestStreak,
        lastActiveDate: todayDate,
      );
    }

    return StreakInfo(
      currentStreak: 1,
      bestStreak: bestStreak,
      lastActiveDate: todayDate,
    );
  }
}