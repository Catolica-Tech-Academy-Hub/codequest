import 'package:codequest/features/xp/domain/entities/task_kind.dart';
import 'package:codequest/features/xp/domain/entities/task_outcome.dart';
import 'package:codequest/features/xp/domain/entities/xp_state.dart';
import 'package:codequest/features/xp/domain/services/xp_calculator.dart';
import 'package:codequest/features/xp/domain/services/xp_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculator = XpCalculator();
  const rules = XpRules();

  final now = DateTime(2026, 6, 14, 10);

  group('XP da tarefa', () {
    test('conteúdo concede XP de conclusão', () {
      final grant = calculator.calculate(
        state: const XpState.initial(),
        outcome: const TaskOutcome(kind: TaskKind.content),
        now: now,
      );
      expect(grant.taskXp, rules.contentXp);
    });

    test('one-choice correta concede XP base cheio', () {
      final grant = calculator.calculate(
        state: const XpState.initial(),
        outcome: const TaskOutcome(kind: TaskKind.oneChoice, wasCorrect: true),
        now: now,
      );
      expect(grant.taskXp, rules.oneChoiceXp);
    });

    test('multi-choice incorreta não concede XP de tarefa (fator 0)', () {
      final grant = calculator.calculate(
        state: const XpState.initial(),
        outcome:
            const TaskOutcome(kind: TaskKind.multiChoice, wasCorrect: false),
        now: now,
      );
      expect(grant.taskXp, 0);
    });

    test('fator de erro configurável é aplicado ao base', () {
      const partial = XpCalculator(rules: XpRules(incorrectFactor: 0.5));
      final grant = partial.calculate(
        state: const XpState.initial(),
        outcome:
            const TaskOutcome(kind: TaskKind.oneChoice, wasCorrect: false),
        now: now,
      );
      expect(grant.taskXp, (rules.oneChoiceXp * 0.5).round());
    });
  });

  group('ofensiva (dias consecutivos)', () {
    test('primeira atividade inicia ofensiva em 1', () {
      final grant = calculator.calculate(
        state: const XpState.initial(),
        outcome: const TaskOutcome(kind: TaskKind.content),
        now: now,
      );
      expect(grant.streakDays, 1);
      expect(grant.startedNewDay, isTrue);
      expect(grant.streakBonus, 1 * rules.streakBonusPerDay);
    });

    test('jogar no dia seguinte incrementa a ofensiva', () {
      final grant = calculator.calculate(
        state: XpState(
          xpTotal: 100,
          streakDays: 4,
          lastActivityDate: DateTime(2026, 6, 13),
        ),
        outcome: const TaskOutcome(kind: TaskKind.oneChoice, wasCorrect: true),
        now: now,
      );
      expect(grant.streakDays, 5);
      expect(grant.startedNewDay, isTrue);
      expect(grant.streakBonus, 5 * rules.streakBonusPerDay);
      expect(grant.totalXp, rules.oneChoiceXp + 5 * rules.streakBonusPerDay);
    });

    test('jogar no mesmo dia mantém a ofensiva sem marcar novo dia', () {
      final grant = calculator.calculate(
        state: XpState(
          xpTotal: 100,
          streakDays: 5,
          lastActivityDate: DateTime(2026, 6, 14),
        ),
        outcome: const TaskOutcome(kind: TaskKind.oneChoice, wasCorrect: true),
        now: now,
      );
      expect(grant.streakDays, 5);
      expect(grant.startedNewDay, isFalse);
    });

    test('intervalo maior que um dia reinicia a ofensiva', () {
      final grant = calculator.calculate(
        state: XpState(
          xpTotal: 100,
          streakDays: 9,
          lastActivityDate: DateTime(2026, 6, 10),
        ),
        outcome: const TaskOutcome(kind: TaskKind.oneChoice, wasCorrect: true),
        now: now,
      );
      expect(grant.streakDays, 1);
      expect(grant.startedNewDay, isTrue);
    });

    test('bônus de ofensiva é limitado pelo teto configurado', () {
      final grant = calculator.calculate(
        state: XpState(
          xpTotal: 1000,
          streakDays: 40,
          lastActivityDate: DateTime(2026, 6, 13),
        ),
        outcome: const TaskOutcome(kind: TaskKind.content),
        now: now,
      );
      expect(grant.streakDays, 41);
      expect(grant.streakBonus, rules.maxStreakForBonus * rules.streakBonusPerDay);
    });
  });

  test('totalXp soma tarefa e bônus de ofensiva', () {
    final grant = calculator.calculate(
      state: XpState(
        xpTotal: 0,
        streakDays: 1,
        lastActivityDate: DateTime(2026, 6, 13),
      ),
      outcome: const TaskOutcome(kind: TaskKind.multiChoice, wasCorrect: true),
      now: now,
    );
    expect(grant.totalXp, grant.taskXp + grant.streakBonus);
    expect(grant.awardedAt, now);
  });
}
