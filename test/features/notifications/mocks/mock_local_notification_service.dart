import 'package:codequest/features/notifications/data/local_notification_service.dart';

class MockLocalNotificationService extends LocalNotificationService {
  bool streakScheduled = false;
  bool streakCancelled = false;
  String? lastPromotionTier;

  MockLocalNotificationService() : super(plugin: null);

  @override
  Future<void> initialize({void Function(String? payload)? onTap}) async {}

  @override
  Future<void> scheduleStreakReminder() async {
    streakScheduled = true;
    streakCancelled = false;
  }

  @override
  Future<void> cancelStreakReminder() async {
    streakCancelled = true;
    streakScheduled = false;
  }

  @override
  Future<void> showPromotionNotification({required String newTier}) async {
    lastPromotionTier = newTier;
  }

  @override
  Future<void> cancelAll() async {
    streakScheduled = false;
    streakCancelled = false;
    lastPromotionTier = null;
  }

  void reset() {
    streakScheduled = false;
    streakCancelled = false;
    lastPromotionTier = null;
  }
}
