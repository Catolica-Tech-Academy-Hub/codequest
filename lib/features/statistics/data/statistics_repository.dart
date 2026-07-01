import 'package:cloud_functions/cloud_functions.dart';

import 'package:codequest/features/statistics/domain/player_stats.dart';
import 'package:codequest/features/statistics/domain/statistics_repository_contract.dart';
import 'package:codequest/features/statistics/domain/xp_history_entry.dart';

/// Implementação que consome a API de Histórico e Estatísticas (Cloud Functions
/// callables `getPlayerStats` / `getXpHistory`). O uid é resolvido no backend a
/// partir do contexto de autenticação, então o cliente não envia identificador.
///
/// Camada: data — único lugar que importa cloud_functions.
class StatisticsRepository implements StatisticsRepositoryContract {
  StatisticsRepository({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  @override
  Future<PlayerStats> fetchPlayerStats() async {
    final callable = _functions.httpsCallable('getPlayerStats');
    final result = await callable.call<Map<String, dynamic>>();
    return _playerStatsFromMap(result.data);
  }

  @override
  Future<List<XpHistoryEntry>> fetchXpHistory({int weeks = 12}) async {
    final callable = _functions.httpsCallable('getXpHistory');
    final result = await callable.call<Map<String, dynamic>>({'weeks': weeks});

    final entries = (result.data['entries'] as List<dynamic>? ?? <dynamic>[]);
    return entries
        .map((dynamic e) => _historyEntryFromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  PlayerStats _playerStatsFromMap(Map<String, dynamic> data) {
    return PlayerStats(
      userId: (data['userId'] as String?) ?? '',
      xpTotal: _asInt(data['xpTotal']),
      position: _asInt(data['position']),
      streakDays: _asInt(data['streakDays']),
      leagueId: (data['leagueId'] as String?) ?? '',
      positionChange: _asInt(data['positionChange']),
    );
  }

  XpHistoryEntry _historyEntryFromMap(Map<String, dynamic> data) {
    return XpHistoryEntry(
      weekStart: DateTime.parse(data['weekStart'] as String),
      xpTotal: _asInt(data['xpTotal']),
      xpGained: _asInt(data['xpGained']),
      streakDays: _asInt(data['streakDays']),
      position: data['position'] == null ? null : _asInt(data['position']),
    );
  }

  // Callables retornam números como int ou double conforme o valor; normaliza.
  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}
