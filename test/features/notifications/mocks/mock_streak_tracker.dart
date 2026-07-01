import 'package:codequest/features/notifications/data/streak_tracker.dart';

class MockStreakTracker extends StreakTracker {
  bool _completed = false;

  void setCompletedToday(bool value) {
    _completed = value;
  }

  @override
  Future<bool> hasCompletedActivityToday() async {
    return _completed;
  }

  @override
  Future<void> markActivityCompleted() async {
    _completed = true;
  }

  @override
  Future<void> clear() async {
    _completed = false;
  }
}
