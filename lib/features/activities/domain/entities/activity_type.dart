enum ActivityType {
  oneChoice('one-choice'),
  multiChoice('multi-choice'),
  content('content');

  const ActivityType(this.wireName);

  final String wireName;

  static ActivityType? tryParse(String raw) {
    for (final value in ActivityType.values) {
      if (value.wireName == raw) {
        return value;
      }
    }
    return null;
  }
}
