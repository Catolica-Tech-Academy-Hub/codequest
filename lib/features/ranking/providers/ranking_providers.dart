import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:codequest/features/ranking/data/mock_ranking_repository.dart';
// 📌 SUBSTITUIÇÃO FUTURA:
// Quando o backend Firestore estiver pronto, descomente os imports abaixo
// e comente/remova o import do MockRankingRepository.
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:codequest/features/ranking/data/ranking_repository.dart';

import 'package:codequest/features/ranking/domain/league_info.dart';
import 'package:codequest/features/ranking/domain/ranking_entry.dart';
import 'package:codequest/features/ranking/domain/ranking_repository_contract.dart';

// =============================================================================
// Provider do repositório
// =============================================================================

/// 📌 SUBSTITUIÇÃO FUTURA:
/// Para usar o repositório real com Firestore, troque a implementação por:
///
/// ```dart
/// final rankingRepositoryProvider = Provider<RankingRepositoryContract>((ref) {
///   return RankingRepository(firestore: FirebaseFirestore.instance);
/// });
/// ```
///
/// A camada de presentation não precisa de nenhuma alteração graças ao
/// Dependency Inversion Principle — ela depende apenas do contrato.
final rankingRepositoryProvider = Provider<RankingRepositoryContract>((ref) {
  return MockRankingRepository();
});

// =============================================================================
// Provider da liga do usuário logado
// =============================================================================

/// 📌 SUBSTITUIÇÃO FUTURA:
/// Quando usar o repositório real, restaurar a leitura do
/// FirebaseAuth.instance.currentUser para obter o uid real:
///
/// ```dart
/// final currentUserLeagueIdProvider = FutureProvider<String?>((ref) async {
///   final user = FirebaseAuth.instance.currentUser;
///   if (user == null) return null;
///   final repo = ref.watch(rankingRepositoryProvider);
///   return repo.fetchUserLeagueId(userId: user.uid);
/// });
/// ```
final currentUserLeagueIdProvider = FutureProvider<String?>((ref) async {
  final repo = ref.watch(rankingRepositoryProvider);
  // Usa ID mockado enquanto não há autenticação real integrada.
  return repo.fetchUserLeagueId(userId: 'mock-user-002');
});

// =============================================================================
// Streams de ranking e liga
// =============================================================================

final leagueRankingStreamProvider =
    StreamProvider.family<List<RankingEntry>, String>((ref, leagueId) {
  final repo = ref.watch(rankingRepositoryProvider);
  // 📌 SUBSTITUIÇÃO FUTURA:
  // Passar o uid real do FirebaseAuth:
  //   currentUserId: FirebaseAuth.instance.currentUser?.uid ?? '',
  return repo.watchLeagueRanking(
    leagueId: leagueId,
    currentUserId: 'mock-user-002',
  );
});

final leagueInfoStreamProvider =
    StreamProvider.family<LeagueInfo, String>((ref, leagueId) {
  final repo = ref.watch(rankingRepositoryProvider);
  return repo.watchLeagueInfo(leagueId: leagueId);
});

final currentUserRankingEntryProvider =
    StreamProvider.family<RankingEntry?, String>((ref, leagueId) {
  return ref.watch(leagueRankingStreamProvider(leagueId).stream).map(
        (entries) => entries.where((e) => e.isCurrentUser).firstOrNull,
      );
});
