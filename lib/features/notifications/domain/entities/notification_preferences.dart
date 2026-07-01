import 'package:equatable/equatable.dart';

class NotificationPreferences extends Equatable {
  const NotificationPreferences({
    this.pushEnabled = true,
    this.streakReminderEnabled = true,
    this.promotionAlertsEnabled = true,
    this.emailEnabled = true,
  });

  final bool pushEnabled;
  final bool streakReminderEnabled;
  final bool promotionAlertsEnabled;
  final bool emailEnabled;

  NotificationPreferences copyWith({
    bool? pushEnabled,
    bool? streakReminderEnabled,
    bool? promotionAlertsEnabled,
    bool? emailEnabled,
  }) {
    return NotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      streakReminderEnabled:
          streakReminderEnabled ?? this.streakReminderEnabled,
      promotionAlertsEnabled:
          promotionAlertsEnabled ?? this.promotionAlertsEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pushEnabled': pushEnabled,
      'streakReminderEnabled': streakReminderEnabled,
      'promotionAlertsEnabled': promotionAlertsEnabled,
      'emailEnabled': emailEnabled,
    };
  }

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      pushEnabled: map['pushEnabled'] as bool? ?? true,
      streakReminderEnabled: map['streakReminderEnabled'] as bool? ?? true,
      promotionAlertsEnabled: map['promotionAlertsEnabled'] as bool? ?? true,
      emailEnabled: map['emailEnabled'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        pushEnabled,
        streakReminderEnabled,
        promotionAlertsEnabled,
        emailEnabled,
      ];
}
