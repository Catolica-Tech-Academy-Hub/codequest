import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:codequest/features/xp/domain/entities/xp_grant.dart';
import 'package:codequest/features/xp/domain/entities/xp_state.dart';
import 'package:codequest/features/xp/domain/repositories/xp_repository_contract.dart';

class FirestoreXpRepository implements XpRepositoryContract {
  FirestoreXpRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  DocumentReference<Map<String, dynamic>> _progressDoc(
    String userId,
    String levelId,
  ) =>
      _userDoc(userId).collection('progress').doc(levelId);

  @override
  Future<XpState> fetchState(String userId) async {
    final snapshot = await _userDoc(userId).get();
    final data = snapshot.data();
    if (data == null) {
      return const XpState.initial();
    }

    final rawDate = data['lastActivityDate'];
    return XpState(
      xpTotal: (data['xpTotal'] as num?)?.toInt() ?? 0,
      streakDays: (data['streakDays'] as num?)?.toInt() ?? 0,
      lastActivityDate: rawDate is Timestamp ? rawDate.toDate() : null,
    );
  }

  @override
  Future<bool> commitLevelCompletion({
    required String userId,
    required String levelId,
    required XpGrant grant,
  }) {
    final userRef = _userDoc(userId);
    final progressRef = _progressDoc(userId, levelId);

    return _firestore.runTransaction<bool>((transaction) async {
      final progressSnap = await transaction.get(progressRef);
      if (progressSnap.exists) {
        return false;
      }

      transaction.set(
        userRef,
        <String, dynamic>{
          'xpTotal': FieldValue.increment(grant.totalXp),
          'streakDays': grant.streakDays,
          'lastActivityDate': Timestamp.fromDate(_dateOnly(grant.awardedAt)),
          'lastXpAwarded': grant.totalXp,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      transaction.set(progressRef, <String, dynamic>{
        'levelId': levelId,
        'xpAwarded': grant.totalXp,
        'completedAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
