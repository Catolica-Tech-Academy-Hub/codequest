import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codequest/features/auth/domain/entities/user_profile.dart';
import 'package:codequest/features/auth/domain/repositories/user_profile_repository_contract.dart';

class UserProfileRepository implements UserProfileRepositoryContract {
  UserProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> createProfile(UserProfile profile) async {
    await _firestore.collection('users').doc(profile.id).set(
      {
        'uid': profile.id,
        'email': profile.email,
        'name': profile.name,
        'avatarUrl': profile.avatarUrl,
        'settings': profile.settings,
        'leagueId': profile.leagueId,
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
      id: data['uid'] as String,
      email: data['email'] as String,
      name: data['name'] as String,
      avatarUrl: data['avatarUrl'] as String?,
      settings: (data['settings'] as Map<String, dynamic>?) ?? const {},
      leagueId: data['leagueId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
