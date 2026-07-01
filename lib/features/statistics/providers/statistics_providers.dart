import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:codequest/features/statistics/application/actions/get_player_stats_action.dart';
import 'package:codequest/features/statistics/application/actions/get_xp_history_action.dart';
import 'package:codequest/features/statistics/data/statistics_repository.dart';
import 'package:codequest/features/statistics/domain/player_stats.dart';
import 'package:codequest/features/statistics/domain/statistics_repository_contract.dart';
import 'package:codequest/features/statistics/domain/xp_history_entry.dart';

final statisticsRepositoryProvider =
    Provider<StatisticsRepositoryContract>((ref) {
  return StatisticsRepository();
});

final getPlayerStatsActionProvider = Provider<GetPlayerStatsAction>((ref) {
  return GetPlayerStatsAction(ref.watch(statisticsRepositoryProvider));
});

final getXpHistoryActionProvider = Provider<GetXpHistoryAction>((ref) {
  return GetXpHistoryAction(ref.watch(statisticsRepositoryProvider));
});

/// Desempenho individual atual do jogador logado.
final playerStatsProvider = FutureProvider<PlayerStats>((ref) {
  return ref.watch(getPlayerStatsActionProvider).call();
});

/// Evolução temporal de XP; parametrizada pela quantidade de semanas.
final xpHistoryProvider =
    FutureProvider.family<List<XpHistoryEntry>, int>((ref, weeks) {
  return ref.watch(getXpHistoryActionProvider).call(weeks: weeks);
});
