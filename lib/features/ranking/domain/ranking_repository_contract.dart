import 'ranking_entry.dart';
import 'league_info.dart';

/// Contrato de acesso aos dados de ranking.
///
/// Camada: domain — apenas abstrações, sem Firebase ou Flutter.
abstract interface class RankingRepositoryContract {
  /// Stream em tempo real do ranking da liga do aluno logado.
  ///
  /// Retorna uma lista ordenada por XP decrescente com no máximo [limit]
  /// entradas. O StreamBuilder da presentation observa este stream
  /// diretamente, garantindo atualizações em tempo real sem polling.
  ///
  /// Otimização de cota Firestore:
  /// - A query filtra apenas os documentos da liga do aluno (`leagueId`).
  /// - Usa `limit(50)` para evitar leitura total da coleção.
  /// - O campo [isCurrentUser] é resolvido no adapter usando o [currentUserId]
  ///   para evitar uma segunda leitura do Firestore.
  Stream<List<RankingEntry>> watchLeagueRanking({
    required String leagueId,
    required String currentUserId,
    int limit = 50,
  });

  /// Stream em tempo real com os dados da liga do aluno.
  Stream<LeagueInfo> watchLeagueInfo({required String leagueId});

  /// Retorna o ID da liga à qual o aluno pertence.
  ///
  /// Leitura única (não stream) — usado apenas na inicialização do provider.
  Future<String?> fetchUserLeagueId({required String userId});
}
