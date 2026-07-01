import 'package:codequest/features/auth/domain/entities/user_profile.dart';
import 'package:codequest/features/auth/providers/auth_providers.dart';
import 'package:codequest/features/profile/application/actions/delete_account_action.dart';
import 'package:codequest/features/profile/application/actions/update_notifications_action.dart';
import 'package:codequest/features/profile/application/actions/update_password_action.dart';
import 'package:codequest/features/profile/application/actions/update_profile_action.dart';
import 'package:codequest/features/profile/presentation/controllers/profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(userProfileRepositoryProvider).getProfile(user.uid);
});

final updateProfileActionProvider = Provider<UpdateProfileAction>((ref) {
  return UpdateProfileAction(
    ref.watch(authRepositoryProvider),
    ref.watch(userProfileRepositoryProvider),
  );
});

final updatePasswordActionProvider = Provider<UpdatePasswordAction>((ref) {
  return UpdatePasswordAction(ref.watch(authRepositoryProvider));
});

final deleteAccountActionProvider = Provider<DeleteAccountAction>((ref) {
  return DeleteAccountAction(
    ref.watch(authRepositoryProvider),
    ref.watch(userProfileRepositoryProvider),
  );
});

final updateNotificationsActionProvider =
    Provider<UpdateNotificationsAction>((ref) {
  return UpdateNotificationsAction(ref.watch(userProfileRepositoryProvider));
});

final profileControllerProvider = Provider<ProfileController>((ref) {
  return ProfileController(
    updateProfileAction: ref.watch(updateProfileActionProvider),
    updatePasswordAction: ref.watch(updatePasswordActionProvider),
    deleteAccountAction: ref.watch(deleteAccountActionProvider),
    updateNotificationsAction: ref.watch(updateNotificationsActionProvider),
  );
});
