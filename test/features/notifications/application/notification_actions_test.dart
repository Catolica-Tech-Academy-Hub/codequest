import 'package:codequest/features/notifications/application/actions/mark_activity_completed_action.dart';
import 'package:codequest/features/notifications/application/actions/save_notification_preferences_action.dart';
import 'package:codequest/features/notifications/application/actions/schedule_streak_reminder_action.dart';
import 'package:codequest/features/notifications/domain/entities/notification_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/mock_local_notification_service.dart';
import '../mocks/mock_notification_repository.dart';
import '../mocks/mock_streak_tracker.dart';

void main() {
  late MockNotificationRepository repository;
  late MockLocalNotificationService localNotifications;
  late MockStreakTracker streakTracker;

  setUp(() {
    repository = MockNotificationRepository();
    localNotifications = MockLocalNotificationService();
    streakTracker = MockStreakTracker();
  });

  group('ScheduleStreakReminderAction', () {
    late ScheduleStreakReminderAction action;

    setUp(() {
      action = ScheduleStreakReminderAction(
        localNotificationService: localNotifications,
        streakTracker: streakTracker,
        notificationRepository: repository,
      );
    });

    test('agenda lembrete quando streak habilitado e sem atividade hoje',
        () async {
      repository.setPreferences(const NotificationPreferences(
        pushEnabled: true,
        streakReminderEnabled: true,
      ),);
      streakTracker.setCompletedToday(false);

      await action.call('user-1');

      expect(localNotifications.streakScheduled, isTrue);
    });

    test('cancela lembrete quando já completou atividade hoje', () async {
      repository.setPreferences(const NotificationPreferences(
        pushEnabled: true,
        streakReminderEnabled: true,
      ),);
      streakTracker.setCompletedToday(true);

      await action.call('user-1');

      expect(localNotifications.streakCancelled, isTrue);
    });

    test('cancela lembrete quando streak desabilitado nas preferências',
        () async {
      repository.setPreferences(const NotificationPreferences(
        pushEnabled: true,
        streakReminderEnabled: false,
      ),);

      await action.call('user-1');

      expect(localNotifications.streakCancelled, isTrue);
    });

    test('cancela lembrete quando push desabilitado nas preferências',
        () async {
      repository.setPreferences(const NotificationPreferences(
        pushEnabled: false,
        streakReminderEnabled: true,
      ),);

      await action.call('user-1');

      expect(localNotifications.streakCancelled, isTrue);
    });
  });

  group('MarkActivityCompletedAction', () {
    late MarkActivityCompletedAction action;

    setUp(() {
      action = MarkActivityCompletedAction(
        streakTracker: streakTracker,
        localNotificationService: localNotifications,
      );
    });

    test('marca atividade e cancela lembrete de streak', () async {
      await action.call();

      expect(await streakTracker.hasCompletedActivityToday(), isTrue);
      expect(localNotifications.streakCancelled, isTrue);
    });
  });

  group('SaveNotificationPreferencesAction', () {
    late SaveNotificationPreferencesAction action;

    setUp(() {
      action = SaveNotificationPreferencesAction(repository);
    });

    test('salva preferências no repositório', () async {
      const prefs = NotificationPreferences(
        pushEnabled: false,
        emailEnabled: false,
      );

      await action.call('user-1', prefs);

      final saved = await repository.getPreferences('user-1');
      expect(saved.pushEnabled, isFalse);
      expect(saved.emailEnabled, isFalse);
    });
  });

  group('NotificationPreferences', () {
    test('serializa e deserializa corretamente', () {
      const prefs = NotificationPreferences(
        pushEnabled: false,
        streakReminderEnabled: true,
        promotionAlertsEnabled: false,
        emailEnabled: true,
      );

      final map = prefs.toMap();
      final restored = NotificationPreferences.fromMap(map);

      expect(restored, equals(prefs));
    });

    test('fromMap usa valores padrão quando campos ausentes', () {
      final prefs = NotificationPreferences.fromMap({});

      expect(prefs.pushEnabled, isTrue);
      expect(prefs.streakReminderEnabled, isTrue);
      expect(prefs.promotionAlertsEnabled, isTrue);
      expect(prefs.emailEnabled, isTrue);
    });

    test('copyWith preserva valores não alterados', () {
      const original = NotificationPreferences(
        pushEnabled: true,
        streakReminderEnabled: true,
        promotionAlertsEnabled: true,
        emailEnabled: true,
      );

      final modified = original.copyWith(pushEnabled: false);

      expect(modified.pushEnabled, isFalse);
      expect(modified.streakReminderEnabled, isTrue);
      expect(modified.promotionAlertsEnabled, isTrue);
      expect(modified.emailEnabled, isTrue);
    });
  });
}
