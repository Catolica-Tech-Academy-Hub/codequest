import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:codequest/features/ranking/domain/league_info.dart';
import 'package:codequest/features/ranking/domain/ranking_entry.dart';
import 'package:codequest/features/ranking/domain/ranking_repository_contract.dart';

// ---------------------------------------------------------------------------
// DTOs
// ---------------------------------------------------------------------------

/// DTO que mapeia o documento Firestore do perfil do aluno.
///
/// Campos esperados na coleção `users/{userId}`:
///   leagueId    : String
///   xpTotal     : int
///   displayName : String
///   streakDays  : int
///   positionChange : int (opcional, padrão 0)
class _UserProfileDto {
  const _UserProfileDto({
    required this.userId,
    required this.displayName,
    required this.xpTotal,
    required this.streakDays,
    required this.leagueId,
    this.positionChange = 0,
  });

  final String userId;
  final String displayName;
  final int xpTotal;
  final int streakDays;
  final String leagueId;
  final int positionChange;

  factory _UserProfileDto.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;
    return _UserProfileDto(
      userId: doc.id,
      displayName: (data['displayName'] as String?) ?? 'Aluno',
      xpTotal: (data['xpTotal'] as int?) ?? 0,
      streakDays: (data['streakDays'] as int?) ?? 0,
      leagueId: (data['leagueId'] as String?) ?? '',
      positionChange: (data['positionChange'] as int?) ?? 0,
    );
  }

  RankingEntry toEntity({
    required int position,
    required bool isCurrentUser,
  }) {
    return RankingEntry(
      userId: userId,
      displayName: displayName,
      xpTotal: xpTotal,
      position: position,
      streakDays: streakDays,
      leagueId: leagueId,
      isCurrentUser: isCurrentUser,
      positionChange: positionChange,
    );
  }
}

/// DTO que mapeia o documento Firestore da liga.
///
/// Campos esperados na coleção `leagues/{leagueId}`:
///   tier                : String ('bronze'|'silver'|'gold'|'diamond')
///   endsAt              : Timestamp
///   promotionThreshold  : int
///   totalParticipants   : int
class _LeagueDto {
  const _LeagueDto({
    required this.leagueId,
    required this.tier,
    required this.endsAt,
    required this.promotionThreshold,
    required this.totalParticipants,
  });

  final String leagueId;
  final String tier;
  final Timestamp endsAt;
  final int promotionThreshold;
  final int totalParticipants;

  factory _LeagueDto.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;
    return _LeagueDto(
      leagueId: doc.id,
      tier: (data['tier'] as String?) ?? 'bronze',
      endsAt: (data['endsAt'] as Timestamp?) ?? Timestamp.now(),
      promotionThreshold: (data['promotionThreshold'] as int?) ?? 15,
      totalParticipants: (data['totalParticipants'] as int?) ?? 0,
    );
  }

  LeagueInfo toEntity() {
    return LeagueInfo(
      leagueId: leagueId,
      tier: _parseTier(tier),
      endsAt: endsAt.toDate(),
      promotionThreshold: promotionThreshold,
      totalParticipants: totalParticipants,
    );
  }

  static LeagueTier _parseTier(String raw) {
    return switch (raw.toLowerCase()) {
      'silver' => LeagueTier.silver,
      'gold' => LeagueTier.gold,
      'diamond' => LeagueTier.diamond,
      _ => LeagueTier.bronze,
    };
  }
}

// ---------------------------------------------------------------------------
// Implementação concreta
// ---------------------------------------------------------------------------

/// Implementação do [RankingRepositoryContract] usando Cloud Firestore.
///
/// Camada: data — único lugar que importa firebase_core/cloud_firestore.
///
/// Estratégia de otimização de cota:
/// 1. A query de ranking filtra por `leagueId` e usa `.limit(limit)`, evitando
///    varredura total da coleção `users`.
/// 2. O listener do Firestore (`.snapshots()`) usa o cache offline do SDK,
///    então leituras repetidas do mesmo documento não consomem cota adicional
///    quando o dado não mudou.
/// 3. O campo `isCurrentUser` é resolvido em memória (sem leitura extra).
class RankingRepository implements RankingRepositoryContract {
  RankingRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<RankingEntry>> watchLeagueRanking({
    required String leagueId,
    required String currentUserId,
    int limit = 50,
  }) {
    // Query otimizada: filtra por liga + ordena por xpTotal desc + limita leituras.
    final query = _firestore
        .collection('users')
        .where('leagueId', isEqualTo: leagueId)
        .orderBy('xpTotal', descending: true)
        .limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.mapIndexed((index, doc) {
        final dto = _UserProfileDto.fromFirestore(doc);
        return dto.toEntity(
          position: index + 1,
          isCurrentUser: doc.id == currentUserId,
        );
      }).toList();
    });
  }

  @override
  Stream<LeagueInfo> watchLeagueInfo({required String leagueId}) {
    return _firestore
        .collection('leagues')
        .doc(leagueId)
        .snapshots()
        .where((snap) => snap.exists)
        .map((snap) => _LeagueDto.fromFirestore(snap).toEntity());
  }

  @override
  Future<String?> fetchUserLeagueId({required String userId}) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return doc.data()?['leagueId'] as String?;
  }
}

// ---------------------------------------------------------------------------
// Extensão auxiliar (sem dependência externa)
// ---------------------------------------------------------------------------
extension _IterableIndexed<T> on Iterable<T> {
  Iterable<R> mapIndexed<R>(R Function(int index, T item) transform) sync* {
    var i = 0;
    for (final item in this) {
      yield transform(i++, item);
    }
  }
}
