import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:codequest/features/notifications/data/fcm_service.dart';
import 'package:codequest/features/notifications/data/local_notification_service.dart';
import 'package:codequest/features/notifications/domain/repositories/notification_repository_contract.dart';

class InitializeNotificationsAction {
  InitializeNotificationsAction({
    required FcmService fcmService,
    required LocalNotificationService localNotificationService,
    required NotificationRepositoryContract notificationRepository,
  })  : _fcmService = fcmService,
        _localNotificationService = localNotificationService,
        _notificationRepository = notificationRepository;

  final FcmService _fcmService;
  final LocalNotificationService _localNotificationService;
  final NotificationRepositoryContract _notificationRepository;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;

  Future<void> call({
    required String uid,
    required void Function(String route) onNavigate,
  }) async {
    await _localNotificationService.initialize(
      onTap: (payload) {
        if (payload != null) onNavigate(payload);
      },
    );

    final granted = await _fcmService.requestPermission();
    if (!granted) return;

    try {
      final token = await _fcmService.getToken();
      if (token != null) {
        await _notificationRepository.saveFcmToken(uid, token);
      }
    } catch (e) {
      debugPrint('Notifications: Erro ao salvar token FCM: $e');
    }

    _tokenRefreshSub = _fcmService.onTokenRefresh().listen((newToken) async {
      try {
        await _notificationRepository.saveFcmToken(uid, newToken);
      } catch (e) {
        debugPrint('Notifications: Erro ao atualizar token FCM: $e');
      }
    });

    _foregroundSub = _fcmService.onForegroundMessage().listen((message) {
      debugPrint('FCM foreground: ${message.notification?.title}');
    });

    _fcmService.onMessageOpenedApp().listen((message) {
      final route = message.data['route'] as String?;
      if (route != null) onNavigate(route);
    });

    try {
      final initialMessage = await _fcmService.getInitialMessage();
      if (initialMessage != null) {
        final route = initialMessage.data['route'] as String?;
        if (route != null) onNavigate(route);
      }
    } catch (e) {
      debugPrint('Notifications: Erro ao processar mensagem inicial: $e');
    }
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
    _foregroundSub?.cancel();
  }
}
