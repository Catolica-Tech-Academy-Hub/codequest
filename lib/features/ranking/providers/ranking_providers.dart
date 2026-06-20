import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:codequest/features/ranking/data/ranking_repository.dart';
import 'package:codequest/features/ranking/domain/league_info.dart';
import 'package:codequest/features/ranking/domain/ranking_entry.dart';
import 'package:codequest/features/ranking/domain/ranking_repository_contract.dart';

part 'ranking_providers.g.dart';

// ---------------------------------------------------------------------------
// Infraestrutura
// ---------------------------------------------------------------------------

@riverpod
RankingRepositoryContract rankingRepository(Ref ref) {
  return RankingRepository(
    firestore: FirebaseFirestore.instance,
  );
}

// ---------------------------------------------------------------------------
// Estado: leagueId do usuário logado
// ---------------------------------------------------------------------------

@riverpod
Future<String?> currentUserLeagueId(Ref ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final repo = ref.watch(rankingRepositoryProvider);
  return repo.fetchUserLeagueId(userId: user.uid);
}

// ---------------------------------------------------------------------------
// Streams em tempo real
// ---------------------------------------------------------------------------

@riverpod
Stream<List<RankingEntry>> leagueRankingStream(Ref ref, String leagueId) {
  final user = FirebaseAuth.instance.currentUser;
  final repo = ref.watch(rankingRepositoryProvider);

  return repo.watchLeagueRanking(
    leagueId: leagueId,
    currentUserId: user?.uid ?? '',
  );
}

@riverpod
Stream<LeagueInfo> leagueInfoStream(Ref ref, String leagueId) {
  final repo = ref.watch(rankingRepositoryProvider);
  return repo.watchLeagueInfo(leagueId: leagueId);
}

// ---------------------------------------------------------------------------
// Estado derivado: entrada do usuário logado no ranking
// ---------------------------------------------------------------------------

@riverpod
Stream<RankingEntry?> currentUserRankingEntry(Ref ref, String leagueId) async* {
  await for (final entries in ref.watch(leagueRankingStreamProvider(leagueId).future).asStream()) {
    yield entries.where((e) => e.isCurrentUser).firstOrNull;
  }
}