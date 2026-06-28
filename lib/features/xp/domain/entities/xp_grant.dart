import 'package:equatable/equatable.dart';

class XpGrant extends Equatable {
  const XpGrant({
    required this.taskXp,
    required this.streakBonus,
    required this.streakDays,
    required this.startedNewDay,
    required this.awardedAt,
  });

  final int taskXp;

  final int streakBonus;

  final int streakDays;

  final bool startedNewDay;

  final DateTime awardedAt;

  int get totalXp => taskXp + streakBonus;

  @override
  List<Object?> get props => [
        taskXp,
        streakBonus,
        streakDays,
        startedNewDay,
        awardedAt,
      ];
}
