import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codequest/features/auth/domain/entities/user_profile.dart';
import 'package:codequest/features/profile/domain/repositories/profile_repository_contract.dart';

/// Implementação Firestore do [ProfileRepositoryContract].
///
/// Responsável exclusivamente pelo acesso a dados — não contém
/// regras de negócio, validações ou lógica de domínio.
class ProfileRepository implements ProfileRepositoryContract {
  ProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) {
      return null;
    }

    final data = doc.data()!;
    return _fromFirestore(data);
  }

  @override
  Future<void> updateSettings(
    String uid,
    Map<String, dynamic> settings,
  ) async {
    await _usersCollection.doc(uid).update({
      'settings': settings,
    });
  }

  // ---------------------------------------------------------------------------
  // Mapeamento interno Firestore → Entidade
  // ---------------------------------------------------------------------------

  UserProfile _fromFirestore(Map<String, dynamic> data) {
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
