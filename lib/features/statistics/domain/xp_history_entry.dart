import 'package:equatable/equatable.dart';

/// Um ponto na evolução temporal de XP (RF07): o snapshot semanal do jogador.
///
/// Camada: domain — entidade pura.
class XpHistoryEntry extends Equatable {
  const XpHistoryEntry({
    required this.weekStart,
    required this.xpTotal,
    required this.xpGained,
    required this.streakDays,
    this.position,
  });

  /// Segunda-feira que inicia a semana representada.
  final DateTime weekStart;

  /// XP acumulado ao final dessa semana.
  final int xpTotal;

  /// XP ganho durante a semana.
  final int xpGained;

  final int streakDays;
  final int? position;

  @override
  List<Object?> get props => [weekStart, xpTotal, xpGained, streakDays, position];
}
