import 'package:flutter/foundation.dart';
import 'package:codequest/features/notifications/data/local_notification_service.dart';
import 'package:codequest/features/notifications/domain/entities/pending_promotion.dart';
import 'package:codequest/features/notifications/domain/repositories/notification_repository_contract.dart';

class CheckPendingPromotionsAction {
  CheckPendingPromotionsAction({
    required NotificationRepositoryContract notificationRepository,
    required LocalNotificationService localNotificationService,
  })  : _notificationRepository = notificationRepository,
        _localNotificationService = localNotificationService;

  final NotificationRepositoryContract _notificationRepository;
  final LocalNotificationService _localNotificationService;

  Stream<List<PendingPromotion>> call(String uid) {
    return _notificationRepository.watchPendingPromotions(uid).map(
      (promotions) {
        for (final promo in promotions) {
          _showAndMark(uid, promo);
        }
        return promotions;
      },
    );
  }

  Future<void> _showAndMark(String uid, PendingPromotion promo) async {
    try {
      await _localNotificationService.showPromotionNotification(
        newTier: promo.newTier,
      );
      await _notificationRepository.markPromotionSeen(uid, promo.id);
    } catch (e) {
      debugPrint('Notifications: Erro ao processar promoção pendente: $e');
    }
  }
}
