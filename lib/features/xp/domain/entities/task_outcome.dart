import 'package:equatable/equatable.dart';

import 'task_kind.dart';

class TaskOutcome extends Equatable {
  const TaskOutcome({
    required this.kind,
    this.wasCorrect = true,
  });

  final TaskKind kind;

  final bool wasCorrect;

  @override
  List<Object?> get props => [kind, wasCorrect];
}
