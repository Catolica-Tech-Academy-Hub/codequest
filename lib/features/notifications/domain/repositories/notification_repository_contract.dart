import 'package:codequest/features/notifications/domain/entities/notification_preferences.dart';
import 'package:codequest/features/notifications/domain/entities/pending_promotion.dart';

abstract class NotificationRepositoryContract {
  Future<NotificationPreferences> getPreferences(String uid);

  Future<void> savePreferences(String uid, NotificationPreferences prefs);

  Future<void> saveFcmToken(String uid, String token);

  Future<void> removeFcmToken(String uid, String token);

  Stream<List<PendingPromotion>> watchPendingPromotions(String uid);

  Future<void> markPromotionSeen(String uid, String promotionId);
}
