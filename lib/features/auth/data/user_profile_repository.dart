import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codequest/features/auth/domain/entities/user_profile.dart';
import 'package:codequest/features/auth/domain/repositories/user_profile_repository_contract.dart';

class UserProfileRepository implements UserProfileRepositoryContract {
  UserProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> createProfile(UserProfile profile) async {
    await _firestore.collection('users').doc(profile.uid).set(
      {
        'uid': profile.uid,
        'email': profile.email,
        'name': profile.name,
        'displayName': profile.name,
        'avatarUrl': profile.avatarUrl,
        'settings': profile.settings,
        'leagueId': profile.leagueId,
        'xpTotal': 0,
        'streakDays': 0,
        'positionChange': 0,
        'bio': profile.bio,
        'notificationsEnabled': profile.notificationsEnabled,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      return null;
    }

    final data = doc.data()!;
    return UserProfile(
      uid: data['uid'] as String,
      email: data['email'] as String,
      name: data['name'] as String,
      leagueId: data['leagueId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      avatarUrl: data['avatarUrl'] as String?,
      settings: (data['settings'] as Map<String, dynamic>?) ?? const {},
      bio: data['bio'] as String?,
      notificationsEnabled: (data['notificationsEnabled'] as bool?) ?? true,
    );
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String name,
    String? bio,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'name': name,
      'displayName': name,
      'bio': bio,
    });
  }

  @override
  Future<void> deleteProfile(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  @override
  Future<void> updateNotificationPreferences({
    required String uid,
    required bool enabled,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'notificationsEnabled': enabled,
    });
  }
}
