import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:codequest/features/ranking/data/ranking_repository.dart';
import 'package:codequest/features/ranking/domain/league_info.dart';
import 'package:codequest/features/ranking/domain/ranking_entry.dart';
import 'package:codequest/features/ranking/domain/ranking_repository_contract.dart';

final rankingRepositoryProvider = Provider<RankingRepositoryContract>((ref) {
  return RankingRepository(
    firestore: FirebaseFirestore.instance,
  );
});

final currentUserLeagueIdProvider = FutureProvider<String?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  final repo = ref.watch(rankingRepositoryProvider);
  return repo.fetchUserLeagueId(userId: user.uid);
});

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

final currentUserRankingEntryProvider =
    Provider.family<AsyncValue<RankingEntry?>, String>((ref, leagueId) {
  final rankingAsync = ref.watch(leagueRankingStreamProvider(leagueId));
  return rankingAsync.whenData(
    (entries) => entries.where((e) => e.isCurrentUser).firstOrNull,
  );
});
