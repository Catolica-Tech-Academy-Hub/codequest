import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/ranking_repository.dart';
import '../domain/league_info.dart';
import '../domain/ranking_entry.dart';
import '../domain/ranking_repository_contract.dart';

part 'ranking_providers.g.dart';

// ---------------------------------------------------------------------------
// Infraestrutura
// ---------------------------------------------------------------------------

/// Fornece a instância do [RankingRepositoryContract].
///
/// Usando [Provider] simples para que o repositório seja compartilhado
/// sem recriações desnecessárias (cache automático do Riverpod).
@riverpod
RankingRepositoryContract rankingRepository(Ref ref) {
  return RankingRepository(
    firestore: FirebaseFirestore.instance,
  );
}

// ---------------------------------------------------------------------------
// Estado: leagueId do usuário logado
// ---------------------------------------------------------------------------

/// Carrega e armazena o leagueId do aluno logado.
///
/// Leitura única ao montar a tela — não consome cota repetidamente.
/// O StreamBuilder da UI usa os providers de stream abaixo, que são
/// eficientes por natureza (SDK Firestore com cache offline).
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

/// Stream do ranking da liga em tempo real.
///
/// Recebe [leagueId] como parâmetro para que o provider seja family-cached
/// por liga — evitando recriação se múltiplas telas observarem a mesma liga.
@riverpod
Stream<List<RankingEntry>> leagueRankingStream(
    Ref ref,
    String leagueId,
    ) {
  final user = FirebaseAuth.instance.currentUser;
  final repo = ref.watch(rankingRepositoryProvider);

  return repo.watchLeagueRanking(
    leagueId: leagueId,
    currentUserId: user?.uid ?? '',
  );
}

/// Stream dos dados da liga em tempo real.
@riverpod
Stream<LeagueInfo> leagueInfoStream(Ref ref, String leagueId) {
  final repo = ref.watch(rankingRepositoryProvider);
  return repo.watchLeagueInfo(leagueId: leagueId);
}

// ---------------------------------------------------------------------------
// Estado derivado: entrada do usuário logado no ranking
// ---------------------------------------------------------------------------

/// Deriva a posição atual do usuário logado a partir do stream do ranking.
///
/// Evita consulta separada ao Firestore — resolve em memória.
@riverpod
Stream<RankingEntry?> currentUserRankingEntry(
    Ref ref,
    String leagueId,
    ) {
  return ref.watch(leagueRankingStreamProvider(leagueId).stream).map(
        (entries) => entries.where((e) => e.isCurrentUser).firstOrNull,
  );
}
