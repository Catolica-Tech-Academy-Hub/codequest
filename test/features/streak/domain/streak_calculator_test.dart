import 'package:flutter_test/flutter_test.dart';
import 'package:codequest/features/streak/domain/streak_calculator.dart';

void main() {
  group('StreakCalculator', () {
    test('deve iniciar streak em 1 quando não existe histórico', () {
      final calculator = StreakCalculator();

      final result = calculator.updateStreak(
        today: DateTime(2026, 6, 16),
        lastActiveDate: null,
        currentStreak: 0,
        bestStreak: 0,
      );

      expect(result.currentStreak, 1);
      expect(result.bestStreak, 1);
    });

    test('deve manter a streak quando o usuário já praticou hoje', () {
      final calculator = StreakCalculator();

      final result = calculator.updateStreak(
        today: DateTime(2026, 6, 16),
        lastActiveDate: DateTime(2026, 6, 16),
        currentStreak: 5,
        bestStreak: 8,
      );

      expect(result.currentStreak, 5);
      expect(result.bestStreak, 8);
    });

    test('deve aumentar a streak quando o usuário praticou ontem', () {
      final calculator = StreakCalculator();

      final result = calculator.updateStreak(
        today: DateTime(2026, 6, 16),
        lastActiveDate: DateTime(2026, 6, 15),
        currentStreak: 5,
        bestStreak: 8,
      );

      expect(result.currentStreak, 6);
      expect(result.bestStreak, 8);
    });

    test('deve atualizar a melhor streak quando a nova streak for maior', () {
      final calculator = StreakCalculator();

      final result = calculator.updateStreak(
        today: DateTime(2026, 6, 16),
        lastActiveDate: DateTime(2026, 6, 15),
        currentStreak: 8,
        bestStreak: 8,
      );

      expect(result.currentStreak, 9);
      expect(result.bestStreak, 9);
    });

    test('deve reiniciar a streak quando o usuário ficar dias sem praticar', () {
      final calculator = StreakCalculator();

      final result = calculator.updateStreak(
        today: DateTime(2026, 6, 16),
        lastActiveDate: DateTime(2026, 6, 13),
        currentStreak: 5,
        bestStreak: 8,
      );

      expect(result.currentStreak, 1);
      expect(result.bestStreak, 8);
    });
  });
}