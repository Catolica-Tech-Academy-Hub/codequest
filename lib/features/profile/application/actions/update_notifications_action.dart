import 'package:codequest/features/auth/domain/repositories/user_profile_repository_contract.dart';

class UpdateNotificationsAction {
  UpdateNotificationsAction(this._profileRepository);

  final UserProfileRepositoryContract _profileRepository;

  Future<void> call({required String uid, required bool enabled}) {
    return _profileRepository.updateNotificationPreferences(
      uid: uid,
      enabled: enabled,
    );
  }
}
