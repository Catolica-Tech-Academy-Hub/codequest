import 'package:equatable/equatable.dart';

/// Nível de liga disponível no sistema de ranking.
enum LeagueTier {
  bronze,
  silver,
  gold,
  diamond;

  /// Rótulo exibido na UI.
  String get label {
    switch (this) {
      case LeagueTier.bronze:
        return 'Bronze';
      case LeagueTier.silver:
        return 'Prata';
      case LeagueTier.gold:
        return 'Ouro';
      case LeagueTier.diamond:
        return 'Diamante';
    }
  }
}

/// Dados da liga ativa do aluno.
///
/// Camada: domain — sem dependências externas.
class LeagueInfo extends Equatable {
  const LeagueInfo({
    required this.leagueId,
    required this.tier,
    required this.endsAt,
    required this.promotionThreshold,
    required this.totalParticipants,
  });

  /// ID do documento Firestore que representa esta liga.
  final String leagueId;

  /// Nível desta liga.
  final LeagueTier tier;

  /// Data/hora de encerramento do período da liga.
  final DateTime endsAt;

  /// Posição mínima para promoção de liga (ex.: top 15).
  final int promotionThreshold;

  /// Total de participantes nesta liga.
  final int totalParticipants;

  /// Dias restantes até o encerramento.
  int get daysRemaining {
    final diff = endsAt.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  @override
  List<Object?> get props => [
    leagueId,
    tier,
    endsAt,
    promotionThreshold,
    totalParticipants,
  ];
}
