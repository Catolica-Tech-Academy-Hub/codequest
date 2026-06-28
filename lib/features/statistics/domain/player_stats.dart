import 'package:equatable/equatable.dart';

/// Desempenho individual do jogador (RF03): posição atual, XP total e sequência.
///
/// Camada: domain — entidade pura, sem dependência de Firebase/Flutter.
class PlayerStats extends Equatable {
  const PlayerStats({
    required this.userId,
    required this.xpTotal,
    required this.position,
    required this.streakDays,
    required this.leagueId,
    required this.positionChange,
  });

  final String userId;
  final int xpTotal;
  final int position;
  final int streakDays;
  final String leagueId;

  /// Variação de posição desde a última semana (+ subiu, − caiu).
  final int positionChange;

  @override
  List<Object?> get props =>
      [userId, xpTotal, position, streakDays, leagueId, positionChange];
}
