import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/user_achievement.dart';
import '../../domain/entities/xp_history_entry.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../models/user_achievement_model.dart';
import '../models/xp_history_entry_model.dart';

/// Implementação do [AchievementRepository] usando Cloud Firestore.
///
/// Estrutura das coleções:
/// ```
/// achievements/                          ← definições globais de conquistas
///   {achievementId}/
///     title, description, type, xpReward, iconPath, targetProgress
///
/// users/{userId}/
///   achievements/                        ← progresso do usuário por conquista
///     {achievementId}/
///       isUnlocked, unlockedAt, currentProgress, targetProgress
///   xp_history/                          ← histórico de ganho de XP
///     {entryId}/
///       xpAmount, source, sourceId, earnedAt
///   stats/                               ← agregações rápidas
///     xp/
///       total
/// ```
class FirestoreAchievementRepository implements AchievementRepository {
  final FirebaseFirestore _firestore;

  FirestoreAchievementRepository(this._firestore);

  // ── Referências de coleção ──────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _achievementsDefs =>
      _firestore.collection('achievements');

  CollectionReference<Map<String, dynamic>> _userAchievements(String userId) =>
      _firestore.collection('users').doc(userId).collection('achievements');

  CollectionReference<Map<String, dynamic>> _xpHistory(String userId) =>
      _firestore.collection('users').doc(userId).collection('xp_history');

  DocumentReference<Map<String, dynamic>> _xpStats(String userId) =>
      _firestore.collection('users').doc(userId).collection('stats').doc('xp');

  // ── Conquistas ──────────────────────────────────────────────────────────────

  @override
  Future<List<UserAchievement>> getAchievements(String userId) async {
    final [defsSnap, progressSnap] = await Future.wait([
      _achievementsDefs.get(),
      _userAchievements(userId).get(),
    ]);

    final defs = _parseDefs(defsSnap as QuerySnapshot<Map<String, dynamic>>);
    return _mergeWithProgress(
      userId: userId,
      defs: defs,
      progressSnap: progressSnap as QuerySnapshot<Map<String, dynamic>>,
    );
  }

  @override
  Stream<List<UserAchievement>> watchAchievements(String userId) {
    // Combina stream de progresso com as definições estáticas.
    return _userAchievements(userId).snapshots().asyncMap((progressSnap) async {
      final defsSnap = await _achievementsDefs.get();
      final defs = _parseDefs(defsSnap);
      return _mergeWithProgress(
        userId: userId,
        defs: defs,
        progressSnap: progressSnap,
      );
    });
  }

  @override
  Future<void> updateAchievementProgress({
    required String userId,
    required String achievementId,
    required int progress,
  }) async {
    // Busca o alvo para saber se deve desbloquear.
    final defDoc = await _achievementsDefs.doc(achievementId).get();
    final targetProgress = defDoc.data()?['targetProgress'] as int? ?? 1;
    final nowUnlocked = progress >= targetProgress;

    final progressRef = _userAchievements(userId).doc(achievementId);
    final snapshot = await progressRef.get();

    if (!snapshot.exists) {
      // Primeira vez que o usuário alcança esta conquista: cria o documento.
      await progressRef.set({
        'achievementId': achievementId,
        'isUnlocked': nowUnlocked,
        'unlockedAt':
            nowUnlocked ? Timestamp.fromDate(DateTime.now()) : null,
        'currentProgress': progress,
        'targetProgress': targetProgress,
      });
    } else {
      // Já existe: atualiza apenas os campos de progresso (sem regredir).
      final currentData = snapshot.data()!;
      final alreadyUnlocked = currentData['isUnlocked'] as bool? ?? false;

      await progressRef.update({
        'currentProgress': progress,
        if (nowUnlocked && !alreadyUnlocked) ...{
          'isUnlocked': true,
          'unlockedAt': Timestamp.fromDate(DateTime.now()),
        },
      });
    }
  }

  // ── Histórico de XP ─────────────────────────────────────────────────────────

  @override
  Future<void> addXpEntry(XpHistoryEntry entry) async {
    final model = XpHistoryEntryModel.fromDomain(entry);

    // Usa batch para gravar a entrada e atualizar o total de XP atomicamente.
    final batch = _firestore.batch();

    batch.set(_xpHistory(entry.userId).doc(entry.id), model.toFirestore());
    batch.set(
      _xpStats(entry.userId),
      {'total': FieldValue.increment(entry.xpAmount)},
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  @override
  Future<List<XpHistoryEntry>> getXpHistory(String userId) async {
    final snap = await _xpHistory(userId)
        .orderBy('earnedAt', descending: true)
        .limit(100)
        .get();

    return snap.docs
        .map((doc) => XpHistoryEntryModel.fromFirestore(doc))
        .toList();
  }

  @override
  Stream<List<XpHistoryEntry>> watchXpHistory(String userId) {
    return _xpHistory(userId)
        .orderBy('earnedAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => XpHistoryEntryModel.fromFirestore(doc)).toList());
  }

  @override
  Future<int> getTotalXp(String userId) async {
    final snap = await _xpStats(userId).get();
    return snap.data()?['total'] as int? ?? 0;
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Map<String, Achievement> _parseDefs(QuerySnapshot<Map<String, dynamic>> snap) {
    return {
      for (final doc in snap.docs)
        doc.id: Achievement(
          id: doc.id,
          title: doc.data()['title'] as String,
          description: doc.data()['description'] as String,
          type: AchievementType.values.firstWhere(
            (e) => e.name == doc.data()['type'],
            orElse: () => AchievementType.xpMilestone,
          ),
          xpReward: doc.data()['xpReward'] as int? ?? 0,
          iconPath: doc.data()['iconPath'] as String? ?? '',
        ),
    };
  }

  List<UserAchievement> _mergeWithProgress({
    required String userId,
    required Map<String, Achievement> defs,
    required QuerySnapshot<Map<String, dynamic>> progressSnap,
  }) {
    final progressMap = {
      for (final doc in progressSnap.docs) doc.id: doc,
    };

    return defs.entries.map((entry) {
      final def = entry.value;
      final progressDoc = progressMap[entry.key];

      if (progressDoc == null) {
        // Usuário ainda não tem progresso nesta conquista.
        return UserAchievementModel(
          userId: userId,
          achievement: def,
          isUnlocked: false,
          currentProgress: 0,
          targetProgress: 1,
        );
      }

      return UserAchievementModel.fromFirestore(
        progressDoc: progressDoc,
        achievement: def,
        userId: userId,
      );
    }).toList();
  }
}
