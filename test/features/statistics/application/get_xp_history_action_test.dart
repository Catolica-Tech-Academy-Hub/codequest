import 'package:codequest/features/statistics/application/actions/get_xp_history_action.dart';
import 'package:codequest/features/statistics/domain/player_stats.dart';
import 'package:codequest/features/statistics/domain/statistics_repository_contract.dart';
import 'package:codequest/features/statistics/domain/xp_history_entry.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeStatisticsRepository implements StatisticsRepositoryContract {
  int? lastWeeks;

  @override
  Future<PlayerStats> fetchPlayerStats() async => throw UnimplementedError();

  @override
  Future<List<XpHistoryEntry>> fetchXpHistory({int weeks = 12}) async {
    lastWeeks = weeks;
    return [
      XpHistoryEntry(
        weekStart: DateTime.utc(2026, 6, 22),
        xpTotal: 120,
        xpGained: 22,
        streakDays: 7,
        position: 2,
      ),
    ];
  }
}

void main() {
  test('repassa o número de semanas e devolve as entradas', () async {
    final repo = _FakeStatisticsRepository();
    final action = GetXpHistoryAction(repo);

    final result = await action.call(weeks: 8);

    expect(repo.lastWeeks, 8);
    expect(result, hasLength(1));
    expect(result.first.xpTotal, 120);
    expect(result.first.xpGained, 22);
  });

  test('usa 12 semanas por padrão', () async {
    final repo = _FakeStatisticsRepository();
    await GetXpHistoryAction(repo).call();
    expect(repo.lastWeeks, 12);
  });
}
