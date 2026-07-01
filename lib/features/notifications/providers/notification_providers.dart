import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:codequest/features/auth/providers/auth_providers.dart';
import 'package:codequest/features/notifications/application/actions/check_pending_promotions_action.dart';
import 'package:codequest/features/notifications/application/actions/initialize_notifications_action.dart';
import 'package:codequest/features/notifications/application/actions/mark_activity_completed_action.dart';
import 'package:codequest/features/notifications/application/actions/save_notification_preferences_action.dart';
import 'package:codequest/features/notifications/application/actions/schedule_streak_reminder_action.dart';
import 'package:codequest/features/notifications/data/fcm_service.dart';
import 'package:codequest/features/notifications/data/local_notification_service.dart';
import 'package:codequest/features/notifications/data/notification_repository.dart';
import 'package:codequest/features/notifications/data/streak_tracker.dart';
import 'package:codequest/features/notifications/domain/entities/notification_preferences.dart';
import 'package:codequest/features/notifications/domain/entities/pending_promotion.dart';
import 'package:codequest/features/notifications/domain/repositories/notification_repository_contract.dart';

final notificationRepositoryProvider =
    Provider<NotificationRepositoryContract>((ref) {
  return NotificationRepository();
});

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService();
});

final localNotificationServiceProvider =
    Provider<LocalNotificationService>((ref) {
  return LocalNotificationService();
});

final streakTrackerProvider = Provider<StreakTracker>((ref) {
  return StreakTracker();
});

final initializeNotificationsActionProvider =
    Provider<InitializeNotificationsAction>((ref) {
  return InitializeNotificationsAction(
    fcmService: ref.watch(fcmServiceProvider),
    localNotificationService: ref.watch(localNotificationServiceProvider),
    notificationRepository: ref.watch(notificationRepositoryProvider),
  );
});

final saveNotificationPreferencesActionProvider =
    Provider<SaveNotificationPreferencesAction>((ref) {
  return SaveNotificationPreferencesAction(
    ref.watch(notificationRepositoryProvider),
  );
});

final scheduleStreakReminderActionProvider =
    Provider<ScheduleStreakReminderAction>((ref) {
  return ScheduleStreakReminderAction(
    localNotificationService: ref.watch(localNotificationServiceProvider),
    streakTracker: ref.watch(streakTrackerProvider),
    notificationRepository: ref.watch(notificationRepositoryProvider),
  );
});

final markActivityCompletedActionProvider =
    Provider<MarkActivityCompletedAction>((ref) {
  return MarkActivityCompletedAction(
    streakTracker: ref.watch(streakTrackerProvider),
    localNotificationService: ref.watch(localNotificationServiceProvider),
  );
});

final checkPendingPromotionsActionProvider =
    Provider<CheckPendingPromotionsAction>((ref) {
  return CheckPendingPromotionsAction(
    notificationRepository: ref.watch(notificationRepositoryProvider),
    localNotificationService: ref.watch(localNotificationServiceProvider),
  );
});

final notificationPreferencesProvider =
    FutureProvider<NotificationPreferences>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const NotificationPreferences();
  return ref.watch(notificationRepositoryProvider).getPreferences(user.uid);
});

final pendingPromotionsProvider =
    StreamProvider<List<PendingPromotion>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref
      .watch(checkPendingPromotionsActionProvider)
      .call(user.uid);
});
