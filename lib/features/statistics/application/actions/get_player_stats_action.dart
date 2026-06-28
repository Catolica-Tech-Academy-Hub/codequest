import 'package:codequest/features/statistics/domain/player_stats.dart';
import 'package:codequest/features/statistics/domain/statistics_repository_contract.dart';

/// Caso de uso: obter o desempenho individual do jogador logado.
class GetPlayerStatsAction {
  const GetPlayerStatsAction(this._repository);

  final StatisticsRepositoryContract _repository;

  Future<PlayerStats> call() => _repository.fetchPlayerStats();
}
