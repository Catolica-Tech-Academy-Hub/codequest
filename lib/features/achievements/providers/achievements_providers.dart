import 'package:codequest/features/achievements/application/actions/check_achievements_action.dart';
import 'package:codequest/features/achievements/data/repositories/achievements_repository_impl.dart';
import 'package:codequest/features/achievements/domain/entities/achievement_status.dart';
import 'package:codequest/features/achievements/domain/repositories/achievements_repository_contract.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final achievementsRepositoryProvider = Provider<AchievementsRepositoryContract>((ref) {
  return AchievementsRepositoryImpl();
});

final checkAchievementsActionProvider = Provider<CheckAchievementsAction>((ref) {
  return CheckAchievementsAction(ref.watch(achievementsRepositoryProvider));
});

final achievementStatusesProvider = StreamProvider<List<AchievementStatus>>((ref) {
  return ref.watch(achievementsRepositoryProvider).watchAll();
});
