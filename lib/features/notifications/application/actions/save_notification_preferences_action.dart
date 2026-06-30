import 'package:flutter/foundation.dart';
import 'package:codequest/features/notifications/domain/entities/notification_preferences.dart';
import 'package:codequest/features/notifications/domain/repositories/notification_repository_contract.dart';

class SaveNotificationPreferencesAction {
  SaveNotificationPreferencesAction(this._repository);

  final NotificationRepositoryContract _repository;

  Future<void> call(String uid, NotificationPreferences prefs) async {
    try {
      await _repository.savePreferences(uid, prefs);
    } catch (e) {
      debugPrint('Notifications: Erro ao salvar preferências: $e');
      rethrow;
    }
  }
}
