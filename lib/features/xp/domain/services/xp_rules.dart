import 'package:codequest/features/xp/domain/entities/task_kind.dart';

class XpRules {
  const XpRules({
    this.contentXp = 10,
    this.oneChoiceXp = 15,
    this.multiChoiceXp = 20,
    this.incorrectFactor = 0.0,
    this.streakBonusPerDay = 2,
    this.maxStreakForBonus = 10,
  });

  final int contentXp;

  final int oneChoiceXp;

  final int multiChoiceXp;

  final double incorrectFactor;

  final int streakBonusPerDay;

  final int maxStreakForBonus;

  int baseXpFor(TaskKind kind) {
    return switch (kind) {
      TaskKind.content => contentXp,
      TaskKind.oneChoice => oneChoiceXp,
      TaskKind.multiChoice => multiChoiceXp,
    };
  }
}
