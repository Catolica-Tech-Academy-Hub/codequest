import 'package:equatable/equatable.dart';

/// Dados da streak atual do usuário.
///
/// Camada: domain - sem dependências externas.
class StreakInfo extends Equatable {
  const StreakInfo({
    required this.currentStreak,
    required this.bestStreak,
    required this.lastActiveDate,
  });

  /// Quantidade atual de dias consecutivos.
  final int currentStreak;

  /// Maior streak já alcançada pelo usuário.
  final int bestStreak;

  /// Última data em que o usuário realizou uma atividade.
  final DateTime lastActiveDate;

  @override
  List<Object?> get props => [
    currentStreak,
    bestStreak,
    lastActiveDate,
  ];
}