import 'package:codequest/features/statistics/domain/player_stats.dart';
import 'package:codequest/features/statistics/domain/xp_history_entry.dart';

/// Contrato de acesso às estatísticas/evolução temporal do jogador logado.
///
/// Camada: domain — implementado em data/ (consome a API de Cloud Functions).
abstract class StatisticsRepositoryContract {
  /// Desempenho individual atual (posição, XP total, sequência).
  Future<PlayerStats> fetchPlayerStats();

  /// Histórico semanal de XP, do mais recente para o mais antigo.
  Future<List<XpHistoryEntry>> fetchXpHistory({int weeks});
}
