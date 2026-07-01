import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:codequest/features/achievements/domain/entities/achievement.dart';
import 'package:codequest/features/achievements/domain/entities/achievement_status.dart';
import 'package:codequest/features/achievements/domain/repositories/achievements_repository_contract.dart';

class AchievementsRepositoryImpl implements AchievementsRepositoryContract {
  AchievementsRepositoryImpl({
    FirebaseFunctions? functions,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _functions = functions ?? FirebaseFunctions.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<List<Achievement>> check() async {
    final callable = _functions.httpsCallable('checkAchievements');
    final result = await callable.call<Map<String, dynamic>>();

    final unlocked = result.data['unlocked'] as List<dynamic>? ?? <dynamic>[];
    return unlocked
        .cast<Map<dynamic, dynamic>>()
        .map(_toAchievement)
        .toList();
  }

  @override
  Stream<List<AchievementStatus>> watchAll() async* {
    final catalog = await _fetchCatalog();
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      yield [
        for (final achievement in catalog)
          AchievementStatus(achievement: achievement, unlocked: false),
      ];
      return;
    }

    yield* _firestore
        .collection('users')
        .doc(uid)
        .collection('achievements')
        .snapshots()
        .map((snapshot) {
      final unlockedAt = <String, DateTime?>{
        for (final doc in snapshot.docs)
          doc.id: (doc.data()['unlockedAt'] as Timestamp?)?.toDate(),
      };

      final statuses = <AchievementStatus>[
        for (final achievement in catalog)
          AchievementStatus(
            achievement: achievement,
            unlocked: unlockedAt.containsKey(achievement.id),
            unlockedAt: unlockedAt[achievement.id],
          ),
      ];

      // Desbloqueadas primeiro, depois por raridade crescente — leitura natural.
      statuses.sort((a, b) {
        if (a.unlocked != b.unlocked) {
          return a.unlocked ? -1 : 1;
        }
        return a.achievement.tier.index.compareTo(b.achievement.tier.index);
      });
      return statuses;
    });
  }

  Future<List<Achievement>> _fetchCatalog() async {
    final snapshot = await _firestore.collection('achievements').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Achievement(
        id: doc.id,
        name: data['name'] as String? ?? doc.id,
        description: data['description'] as String? ?? '',
        iconKey: data['iconKey'] as String? ?? '',
        tier: AchievementTier.fromKey(data['tier'] as String?),
        category: data['category'] as String? ?? '',
      );
    }).toList();
  }

  Achievement _toAchievement(Map<dynamic, dynamic> raw) {
    return Achievement(
      id: raw['id'] as String,
      name: raw['name'] as String,
      description: raw['description'] as String,
      iconKey: raw['iconKey'] as String,
      tier: AchievementTier.fromKey(raw['tier'] as String?),
      category: raw['category'] as String,
    );
  }
}
