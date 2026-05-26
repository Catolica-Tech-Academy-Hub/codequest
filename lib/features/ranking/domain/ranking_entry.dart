import 'package:equatable/equatable.dart';

/// Representa a entrada de um aluno no ranking da liga.
///
/// Camada: domain — sem dependências externas.
class RankingEntry extends Equatable {
  const RankingEntry({
    required this.userId,
    required this.displayName,
    required this.xpTotal,
    required this.position,
    required this.streakDays,
    required this.leagueId,
    this.isCurrentUser = false,
    this.positionChange = 0,
  });

  /// ID do usuário no Firebase Auth.
  final String userId;

  /// Nome de exibição do aluno.
  final String displayName;

  /// Total de XP acumulado.
  final int xpTotal;

  /// Posição no ranking (1-indexed).
  final int position;

  /// Sequência de dias consecutivos de estudo.
  final int streakDays;

  /// ID da liga à qual o aluno pertence.
  final String leagueId;

  /// Indica se esta entrada representa o usuário logado.
  final bool isCurrentUser;

  /// Variação de posição desde a última atualização (+/- n posições).
  final int positionChange;

  @override
  List<Object?> get props => [
    userId,
    displayName,
    xpTotal,
    position,
    streakDays,
    leagueId,
    isCurrentUser,
    positionChange,
  ];
}
