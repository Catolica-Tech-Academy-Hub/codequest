import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/league_info.dart';
import '../domain/ranking_entry.dart';

part 'ranking_providers.g.dart';

const _mockUserId = 'mock-user-id';
const _mockLeagueId = 'league-gold-001';

final _mockEntries = [
  RankingEntry(
    userId: 'user-001',
    displayName: 'Luna Star',
    xpTotal: 2850,
    position: 1,
    streakDays: 15,
    leagueId: _mockLeagueId,
    positionChange: 2,
  ),
  RankingEntry(
    userId: 'user-002',
    displayName: 'Max Power',
    xpTotal: 2420,
    position: 2,
    streakDays: 12,
    leagueId: _mockLeagueId,
    positionChange: -1,
  ),
  RankingEntry(
    userId: 'user-003',
    displayName: 'Pixel Ninja',
    xpTotal: 2100,
    position: 3,
    streakDays: 20,
    leagueId: _mockLeagueId,
    positionChange: 0,
  ),
  RankingEntry(
    userId: _mockUserId,
    displayName: 'Você',
    xpTotal: 1890,
    position: 4,
    streakDays: 8,
    leagueId: _mockLeagueId,
    isCurrentUser: true,
    positionChange: 1,
  ),
  RankingEntry(
    userId: 'user-005',
    displayName: 'Byte Queen',
    xpTotal: 1650,
    position: 5,
    streakDays: 10,
    leagueId: _mockLeagueId,
    positionChange: -2,
  ),
  RankingEntry(
    userId: 'user-006',
    displayName: 'Code Wizard',
    xpTotal: 1430,
    position: 6,
    streakDays: 6,
    leagueId: _mockLeagueId,
    positionChange: 3,
  ),
  RankingEntry(
    userId: 'user-007',
    displayName: 'Data Fox',
    xpTotal: 1280,
    position: 7,
    streakDays: 9,
    leagueId: _mockLeagueId,
    positionChange: 0,
  ),
  RankingEntry(
    userId: 'user-008',
    displayName: 'Shell Ghost',
    xpTotal: 990,
    position: 8,
    streakDays: 4,
    leagueId: _mockLeagueId,
    positionChange: -1,
  ),
];

final _mockLeagueInfo = LeagueInfo(
  leagueId: _mockLeagueId,
  tier: LeagueTier.gold,
  endsAt: DateTime.now().add(const Duration(days: 5, hours: 14)),
  promotionThreshold: 5,
  totalParticipants: 8,
);

@riverpod
Future<String?> currentUserLeagueId(Ref ref) async {
  return _mockLeagueId;
}

@riverpod
Stream<List<RankingEntry>> leagueRankingStream(Ref ref, String leagueId) {
  return Stream.value(_mockEntries);
}

@riverpod
Stream<LeagueInfo> leagueInfoStream(Ref ref, String leagueId) {
  return Stream.value(_mockLeagueInfo);
}
