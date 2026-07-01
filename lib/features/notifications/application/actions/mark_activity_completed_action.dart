import 'package:flutter/foundation.dart';
import 'package:codequest/features/notifications/data/local_notification_service.dart';
import 'package:codequest/features/notifications/data/streak_tracker.dart';

class MarkActivityCompletedAction {
  MarkActivityCompletedAction({
    required StreakTracker streakTracker,
    required LocalNotificationService localNotificationService,
  })  : _streakTracker = streakTracker,
        _localNotificationService = localNotificationService;

  final StreakTracker _streakTracker;
  final LocalNotificationService _localNotificationService;

  Future<void> call() async {
    try {
      await _streakTracker.markActivityCompleted();
      await _localNotificationService.cancelStreakReminder();
    } catch (e) {
      debugPrint('Notifications: Erro ao marcar atividade completa: $e');
    }
  }
}
