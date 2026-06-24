import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const _streakReminderId = 1001;

class LocalNotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const _channelId = 'codequest_streak';
  static const _channelName = 'Lembrete de Streak';
  static const _channelDescription = 'Lembrete diário para manter sua sequência';

  Future<void> initialize({
    void Function(String? payload)? onTap,
  }) async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        onTap?.call(response.payload);
      },
    );
  }

  /// Agenda lembrete de streak para as 20h do horário local.
  /// Se já passou das 20h hoje, agenda para amanhã.
  Future<void> scheduleStreakReminder() async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        20,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        _streakReminderId,
        'Não perca sua sequência! 🔥',
        'Você ainda não completou nenhuma atividade hoje. '
            'Entre agora e mantenha seu streak!',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: '/home/trails',
        matchDateTimeComponents: null,
      );
    } catch (e) {
      debugPrint('LocalNotification: Erro ao agendar streak reminder: $e');
    }
  }

  Future<void> cancelStreakReminder() async {
    try {
      await _plugin.cancel(_streakReminderId);
    } catch (e) {
      debugPrint('LocalNotification: Erro ao cancelar streak reminder: $e');
    }
  }

  Future<void> showPromotionNotification({
    required String newTier,
  }) async {
    try {
      final tierLabels = {
        'silver': 'Prata',
        'gold': 'Ouro',
        'diamond': 'Diamante',
      };
      final tierLabel = tierLabels[newTier] ?? newTier;

      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'Parabéns! Você foi promovido! 🏆',
        'Você subiu para a liga $tierLabel! Continue assim!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'codequest_promotion',
            'Promoção de Liga',
            channelDescription: 'Notificações de promoção de liga',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: '/home/ranking',
      );
    } catch (e) {
      debugPrint('LocalNotification: Erro ao mostrar promoção: $e');
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
