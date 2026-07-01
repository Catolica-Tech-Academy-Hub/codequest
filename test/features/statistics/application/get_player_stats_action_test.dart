import 'package:codequest/features/statistics/application/actions/get_player_stats_action.dart';
import 'package:codequest/features/statistics/domain/player_stats.dart';
import 'package:codequest/features/statistics/domain/statistics_repository_contract.dart';
import 'package:codequest/features/statistics/domain/xp_history_entry.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeStatisticsRepository implements StatisticsRepositoryContract {
  _FakeStatisticsRepository(this._stats);

  final PlayerStats _stats;

  @override
  Future<PlayerStats> fetchPlayerStats() async => _stats;

  @override
  Future<List<XpHistoryEntry>> fetchXpHistory({int weeks = 12}) async =>
      <XpHistoryEntry>[];
}

void main() {
  test('retorna o desempenho individual do repositório', () async {
    const stats = PlayerStats(
      userId: 'dev-001',
      xpTotal: 120,
      position: 2,
      streakDays: 7,
      leagueId: 'bronze-001',
      positionChange: 1,
    );
    final action = GetPlayerStatsAction(_FakeStatisticsRepository(stats));

    final result = await action.call();

    expect(result, stats);
    expect(result.position, 2);
    expect(result.xpTotal, 120);
  });
}
