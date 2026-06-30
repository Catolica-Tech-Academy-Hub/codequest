import 'package:flutter/foundation.dart';
import 'package:codequest/features/notifications/data/local_notification_service.dart';
import 'package:codequest/features/notifications/data/streak_tracker.dart';
import 'package:codequest/features/notifications/domain/repositories/notification_repository_contract.dart';

class ScheduleStreakReminderAction {
  ScheduleStreakReminderAction({
    required LocalNotificationService localNotificationService,
    required StreakTracker streakTracker,
    required NotificationRepositoryContract notificationRepository,
  })  : _localNotificationService = localNotificationService,
        _streakTracker = streakTracker,
        _notificationRepository = notificationRepository;

  final LocalNotificationService _localNotificationService;
  final StreakTracker _streakTracker;
  final NotificationRepositoryContract _notificationRepository;

  Future<void> call(String uid) async {
    try {
      final prefs = await _notificationRepository.getPreferences(uid);

      if (!prefs.streakReminderEnabled || !prefs.pushEnabled) {
        await _localNotificationService.cancelStreakReminder();
        return;
      }

      final completedToday = await _streakTracker.hasCompletedActivityToday();

      if (completedToday) {
        await _localNotificationService.cancelStreakReminder();
      } else {
        await _localNotificationService.scheduleStreakReminder();
      }
    } catch (e) {
      debugPrint('Notifications: Erro ao agendar streak reminder: $e');
    }
  }
}
