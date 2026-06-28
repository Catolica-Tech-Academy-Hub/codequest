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
        // Campos lidos pelo ranking; inicializados no cadastro para que o aluno
        // já apareça na liga com 0 XP.
        'displayName': profile.name,
        'leagueId': profile.leagueId,
        'xpTotal': 0,
        'streakDays': 0,
        'positionChange': 0,
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
    );
  }
}
