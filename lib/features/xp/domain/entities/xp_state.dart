import 'package:equatable/equatable.dart';

class XpState extends Equatable {
  const XpState({
    required this.xpTotal,
    required this.streakDays,
    required this.lastActivityDate,
  });

  const XpState.initial()
      : xpTotal = 0,
        streakDays = 0,
        lastActivityDate = null;

  final int xpTotal;

  final int streakDays;

  final DateTime? lastActivityDate;

  @override
  List<Object?> get props => [xpTotal, streakDays, lastActivityDate];
}
