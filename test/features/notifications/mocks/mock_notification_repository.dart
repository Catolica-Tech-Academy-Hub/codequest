import 'package:codequest/features/notifications/domain/entities/notification_preferences.dart';
import 'package:codequest/features/notifications/domain/entities/pending_promotion.dart';
import 'package:codequest/features/notifications/domain/repositories/notification_repository_contract.dart';

class MockNotificationRepository implements NotificationRepositoryContract {
  NotificationPreferences _prefs = const NotificationPreferences();
  final List<String> savedTokens = [];
  final List<String> removedTokens = [];
  final List<PendingPromotion> _promotions = [];
  final Set<String> seenPromotions = {};

  @override
  Future<NotificationPreferences> getPreferences(String uid) async {
    return _prefs;
  }

  @override
  Future<void> savePreferences(String uid, NotificationPreferences prefs) async {
    _prefs = prefs;
  }

  @override
  Future<void> saveFcmToken(String uid, String token) async {
    savedTokens.add(token);
  }

  @override
  Future<void> removeFcmToken(String uid, String token) async {
    removedTokens.add(token);
  }

  @override
  Stream<List<PendingPromotion>> watchPendingPromotions(String uid) {
    return Stream.value(_promotions);
  }

  @override
  Future<void> markPromotionSeen(String uid, String promotionId) async {
    seenPromotions.add(promotionId);
  }

  void setPreferences(NotificationPreferences prefs) {
    _prefs = prefs;
  }

  void addPromotion(PendingPromotion promo) {
    _promotions.add(promo);
  }
}
