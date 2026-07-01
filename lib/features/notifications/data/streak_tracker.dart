import 'package:shared_preferences/shared_preferences.dart';

class StreakTracker {
  static const _keyLastActivityDate = 'streak_last_activity_date';

  Future<bool> hasCompletedActivityToday() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_keyLastActivityDate);
    if (stored == null) return false;

    final lastDate = DateTime.tryParse(stored);
    if (lastDate == null) return false;

    final now = DateTime.now();
    return lastDate.year == now.year &&
        lastDate.month == now.month &&
        lastDate.day == now.day;
  }

  Future<void> markActivityCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(_keyLastActivityDate, today);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastActivityDate);
  }
}
