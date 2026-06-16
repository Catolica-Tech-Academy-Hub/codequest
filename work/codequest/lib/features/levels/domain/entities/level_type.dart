enum LevelType {
  oneChoice('one-choice'),
  multiChoice('multi-choice'),
  content('content');

  const LevelType(this.wireName);

  final String wireName;

  static LevelType? tryParse(String raw) {
    for (final value in LevelType.values) {
      if (value.wireName == raw) {
        return value;
      }
    }
    return null;
  }
}
