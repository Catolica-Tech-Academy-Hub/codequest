import 'package:codequest/features/profile/application/actions/delete_account_action.dart';
import 'package:codequest/features/profile/application/actions/update_notifications_action.dart';
import 'package:codequest/features/profile/application/actions/update_password_action.dart';
import 'package:codequest/features/profile/application/actions/update_profile_action.dart';

class ProfileController {
  ProfileController({
    required UpdateProfileAction updateProfileAction,
    required UpdatePasswordAction updatePasswordAction,
    required DeleteAccountAction deleteAccountAction,
    required UpdateNotificationsAction updateNotificationsAction,
  })  : _updateProfile = updateProfileAction,
        _updatePassword = updatePasswordAction,
        _deleteAccount = deleteAccountAction,
        _updateNotifications = updateNotificationsAction;

  final UpdateProfileAction _updateProfile;
  final UpdatePasswordAction _updatePassword;
  final DeleteAccountAction _deleteAccount;
  final UpdateNotificationsAction _updateNotifications;

  Future<void> updateProfile({
    required String uid,
    required String name,
    String? bio,
  }) {
    return _updateProfile.call(uid: uid, name: name, bio: bio);
  }

  Future<void> updatePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _updatePassword.call(
      email: email,
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  Future<void> deleteAccount({required String uid}) {
    return _deleteAccount.call(uid: uid);
  }

  Future<void> updateNotifications({
    required String uid,
    required bool enabled,
  }) {
    return _updateNotifications.call(uid: uid, enabled: enabled);
  }
}
