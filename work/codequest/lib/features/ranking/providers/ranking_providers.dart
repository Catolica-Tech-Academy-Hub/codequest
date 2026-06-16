import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codequest/features/ranking/data/ranking_repository.dart';
import 'package:codequest/features/ranking/domain/league_info.dart';
import 'package:codequest/features/ranking/domain/ranking_entry.dart';
import 'package:codequest/features/ranking/domain/ranking_repository_contract.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Infraestrutura
// ---------------------------------------------------------------------------

final rankingRepositoryProvider = Provider<RankingRepositoryContract>((ref) {
  return RankingRepository(
    firestore: FirebaseFirestore.instance,
  );
});

// ---------------------------------------------------------------------------
// Estado: leagueId do usuario logado
// ---------------------------------------------------------------------------

final currentUserLeagueIdProvider = FutureProvider<String?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final repo = ref.watch(rankingRepositoryProvider);
  return repo.fetchUserLeagueId(userId: user.uid);
});

// ---------------------------------------------------------------------------
// Streams em tempo real
// ---------------------------------------------------------------------------

final leagueRankingStreamProvider =
    StreamProvider.family<List<RankingEntry>, String>((ref, leagueId) {
  final user = FirebaseAuth.instance.currentUser;
  final repo = ref.watch(rankingRepositoryProvider);

  return repo.watchLeagueRanking(
    leagueId: leagueId,
    currentUserId: user?.uid ?? '',
  );
});

final leagueInfoStreamProvider =
    StreamProvider.family<LeagueInfo, String>((ref, leagueId) {
  final repo = ref.watch(rankingRepositoryProvider);
  return repo.watchLeagueInfo(leagueId: leagueId);
});

// ---------------------------------------------------------------------------
// Estado derivado: entrada do usuario logado no ranking
// ---------------------------------------------------------------------------

final currentUserRankingEntryProvider =
    StreamProvider.family<RankingEntry?, String>((ref, leagueId) {
  final user = FirebaseAuth.instance.currentUser;
  final repo = ref.watch(rankingRepositoryProvider);

  return repo
      .watchLeagueRanking(
    leagueId: leagueId,
    currentUserId: user?.uid ?? '',
  )
      .map(
    (entries) {
      for (final entry in entries) {
        if (entry.isCurrentUser) return entry;
      }
      return null;
    },
  );
});
