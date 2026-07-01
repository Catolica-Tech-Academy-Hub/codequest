import 'package:codequest/features/statistics/domain/statistics_repository_contract.dart';
import 'package:codequest/features/statistics/domain/xp_history_entry.dart';

/// Caso de uso: obter a evolução temporal de XP do jogador logado.
class GetXpHistoryAction {
  const GetXpHistoryAction(this._repository);

  final StatisticsRepositoryContract _repository;

  Future<List<XpHistoryEntry>> call({int weeks = 12}) =>
      _repository.fetchXpHistory(weeks: weeks);
}
