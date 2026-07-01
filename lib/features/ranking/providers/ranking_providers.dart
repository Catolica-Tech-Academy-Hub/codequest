import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:codequest/features/ranking/data/ranking_repository.dart';
import 'package:codequest/features/ranking/domain/league_info.dart';
import 'package:codequest/features/ranking/domain/ranking_entry.dart';
import 'package:codequest/features/ranking/domain/ranking_repository_contract.dart';

// ---------------------------------------------------------------------------
// Infraestrutura
// ---------------------------------------------------------------------------

/// Fornece a instância do [RankingRepositoryContract].
///
/// Usando [Provider] simples para que o repositório seja compartilhado
/// sem recriações desnecessárias (cache automático do Riverpod).
final rankingRepositoryProvider = Provider<RankingRepositoryContract>((ref) {
  return RankingRepository(
    firestore: FirebaseFirestore.instance,
  );
});

// ---------------------------------------------------------------------------
// Estado: leagueId do usuário logado
// ---------------------------------------------------------------------------

/// Carrega e armazena o leagueId do aluno logado.
///
/// Leitura única ao montar a tela — não consome cota repetidamente.
/// O StreamBuilder da UI usa os providers de stream abaixo, que são
/// eficientes por natureza (SDK Firestore com cache offline).
final currentUserLeagueIdProvider = FutureProvider<String?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  final repo = ref.watch(rankingRepositoryProvider);
  return repo.fetchUserLeagueId(userId: user.uid);
});

// ---------------------------------------------------------------------------
// Streams em tempo real
// ---------------------------------------------------------------------------

/// Stream do ranking da liga em tempo real.
///
/// Recebe [leagueId] como parâmetro para que o provider seja family-cached
/// por liga — evitando recriação se múltiplas telas observarem a mesma liga.
final leagueRankingStreamProvider =
    StreamProvider.family<List<RankingEntry>, String>((ref, leagueId) {
  final user = FirebaseAuth.instance.currentUser;
  final repo = ref.watch(rankingRepositoryProvider);
  return repo.watchLeagueRanking(
    leagueId: leagueId,
    currentUserId: user?.uid ?? '',
  );
});

/// Stream dos dados da liga em tempo real.
final leagueInfoStreamProvider =
    StreamProvider.family<LeagueInfo, String>((ref, leagueId) {
  final repo = ref.watch(rankingRepositoryProvider);
  return repo.watchLeagueInfo(leagueId: leagueId);
});

// ---------------------------------------------------------------------------
// Estado derivado: entrada do usuário logado no ranking
// ---------------------------------------------------------------------------

/// Deriva a posição atual do usuário logado a partir do estado já observado
/// do ranking, sem abrir uma assinatura adicional.
final currentUserRankingEntryProvider =
    Provider.family<AsyncValue<RankingEntry?>, String>((ref, leagueId) {
  final rankingAsync = ref.watch(leagueRankingStreamProvider(leagueId));
  return rankingAsync.whenData(
    (entries) => entries.where((e) => e.isCurrentUser).firstOrNull,
  );
});
