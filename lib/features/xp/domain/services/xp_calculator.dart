import 'package:codequest/features/xp/domain/entities/task_kind.dart';
import 'package:codequest/features/xp/domain/entities/task_outcome.dart';
import 'package:codequest/features/xp/domain/entities/xp_grant.dart';
import 'package:codequest/features/xp/domain/entities/xp_state.dart';
import 'package:codequest/features/xp/domain/services/xp_rules.dart';

class XpCalculator {
  const XpCalculator({this.rules = const XpRules()});

  final XpRules rules;

  XpGrant calculate({
    required XpState state,
    required TaskOutcome outcome,
    required DateTime now,
  }) {
    final streak = _resolveStreak(
      currentStreak: state.streakDays,
      lastActivityDate: state.lastActivityDate,
      now: now,
    );

    final taskXp = _taskXp(outcome);
    final streakBonus = _streakBonus(streak.days);

    return XpGrant(
      taskXp: taskXp,
      streakBonus: streakBonus,
      streakDays: streak.days,
      startedNewDay: streak.isNewDay,
      awardedAt: now,
    );
  }

  int _taskXp(TaskOutcome outcome) {
    final base = rules.baseXpFor(outcome.kind);
    if (outcome.kind == TaskKind.content || outcome.wasCorrect) {
      return base;
    }
    return (base * rules.incorrectFactor).round();
  }

  int _streakBonus(int streakDays) {
    final int effectiveDays;
    if (streakDays < 0) {
      effectiveDays = 0;
    } else if (streakDays > rules.maxStreakForBonus) {
      effectiveDays = rules.maxStreakForBonus;
    } else {
      effectiveDays = streakDays;
    }
    return effectiveDays * rules.streakBonusPerDay;
  }

  ({int days, bool isNewDay}) _resolveStreak({
    required int currentStreak,
    required DateTime? lastActivityDate,
    required DateTime now,
  }) {
    if (lastActivityDate == null) {
      return (days: 1, isNewDay: true);
    }

    final dayGap = _daysBetween(lastActivityDate, now);

    if (dayGap <= 0) {
      return (days: currentStreak < 1 ? 1 : currentStreak, isNewDay: false);
    }
    if (dayGap == 1) {
      return (days: currentStreak + 1, isNewDay: true);
    }
    return (days: 1, isNewDay: true);
  }

  int _daysBetween(DateTime from, DateTime to) {
    final f = DateTime(from.year, from.month, from.day);
    final t = DateTime(to.year, to.month, to.day);
    return t.difference(f).inDays;
  }
}
