import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/firestore_achievement_repository.dart';
import '../domain/entities/user_achievement.dart';
import '../domain/entities/xp_history_entry.dart';
import '../domain/repositories/achievement_repository.dart';
import '../domain/use_cases/get_achievements_use_case.dart';
import '../domain/use_cases/record_xp_gain_use_case.dart';
import '../domain/use_cases/update_streak_progress_use_case.dart';

// ── Infraestrutura ──────────────────────────────────────────────────────────

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return FirestoreAchievementRepository(FirebaseFirestore.instance);
});

// ── Use Cases ───────────────────────────────────────────────────────────────

final getAchievementsUseCaseProvider = Provider<GetAchievementsUseCase>((ref) {
  return GetAchievementsUseCase(ref.watch(achievementRepositoryProvider));
});

final recordXpGainUseCaseProvider = Provider<RecordXpGainUseCase>((ref) {
  return RecordXpGainUseCase(ref.watch(achievementRepositoryProvider));
});

final updateStreakProgressUseCaseProvider =
    Provider<UpdateStreakProgressUseCase>((ref) {
  return UpdateStreakProgressUseCase(ref.watch(achievementRepositoryProvider));
});

// ── Estado reativo ───────────────────────────────────────────────────────────

/// Stream das conquistas do usuário autenticado.
final userAchievementsProvider =
    StreamProvider.family<List<UserAchievement>, String>((ref, userId) {
  return ref.watch(getAchievementsUseCaseProvider).watch(userId);
});

/// Stream do histórico de XP do usuário autenticado.
final xpHistoryProvider =
    StreamProvider.family<List<XpHistoryEntry>, String>((ref, userId) {
  return ref
      .watch(achievementRepositoryProvider)
      .watchXpHistory(userId);
});

/// XP total do usuário (futuro, carregado uma vez).
final totalXpProvider = FutureProvider.family<int, String>((ref, userId) {
  return ref.watch(achievementRepositoryProvider).getTotalXp(userId);
});
