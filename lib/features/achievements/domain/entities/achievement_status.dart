import 'package:codequest/features/achievements/domain/entities/achievement.dart';

class AchievementStatus {
  const AchievementStatus({
    required this.achievement,
    required this.unlocked,
    this.unlockedAt,
  });

  final Achievement achievement;
  final bool unlocked;
  final DateTime? unlockedAt;
}
