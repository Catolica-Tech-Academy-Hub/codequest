import 'package:codequest/features/auth/domain/entities/user_profile.dart';

abstract class UserProfileRepositoryContract {
  Future<void> createProfile(UserProfile profile);

  Future<UserProfile?> getProfile(String uid);

  Future<void> updateProfile({
    required String uid,
    required String name,
    String? bio,
  });

  Future<void> deleteProfile(String uid);

  Future<void> updateNotificationPreferences({
    required String uid,
    required bool enabled,
  });
}
