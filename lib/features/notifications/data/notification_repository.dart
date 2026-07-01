import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codequest/features/notifications/domain/entities/notification_preferences.dart';
import 'package:codequest/features/notifications/domain/entities/pending_promotion.dart';
import 'package:codequest/features/notifications/domain/repositories/notification_repository_contract.dart';

class NotificationRepository implements NotificationRepositoryContract {
  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<NotificationPreferences> getPreferences(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null || data['notificationPreferences'] == null) {
      return const NotificationPreferences();
    }
    return NotificationPreferences.fromMap(
      Map<String, dynamic>.from(data['notificationPreferences'] as Map),
    );
  }

  @override
  Future<void> savePreferences(
    String uid,
    NotificationPreferences prefs,
  ) async {
    await _firestore.collection('users').doc(uid).set(
      {'notificationPreferences': prefs.toMap()},
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> saveFcmToken(String uid, String token) async {
    await _firestore.collection('users').doc(uid).set(
      {
        'fcmTokens': FieldValue.arrayUnion([token]),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> removeFcmToken(String uid, String token) async {
    await _firestore.collection('users').doc(uid).set(
      {
        'fcmTokens': FieldValue.arrayRemove([token]),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Stream<List<PendingPromotion>> watchPendingPromotions(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('type', isEqualTo: 'league_promotion')
        .where('seen', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return PendingPromotion(
          id: doc.id,
          userId: uid,
          oldTier: data['oldTier'] as String? ?? '',
          newTier: data['newTier'] as String? ?? '',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
              DateTime.now(),
          seen: data['seen'] as bool? ?? false,
        );
      }).toList();
    });
  }

  @override
  Future<void> markPromotionSeen(String uid, String promotionId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(promotionId)
        .update({'seen': true});
  }
}
