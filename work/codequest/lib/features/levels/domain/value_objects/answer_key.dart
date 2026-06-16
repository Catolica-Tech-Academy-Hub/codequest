import 'package:codequest/features/levels/domain/errors/level_failure.dart';

class AnswerKey {
  AnswerKey(String raw) : value = raw {
    if (!_pattern.hasMatch(raw)) {
      throw LevelFailure.invalidAnswerKey(raw);
    }
  }

  static final RegExp _pattern = RegExp(r'^[a-z]$');

  final String value;

  @override
  bool operator ==(Object other) => other is AnswerKey && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
