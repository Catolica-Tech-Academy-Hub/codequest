import 'package:codequest/features/auth/domain/entities/user_profile.dart';

abstract class UserProfileRepositoryContract {
  Future<void> createProfile(UserProfile profile);

  Future<UserProfile?> getProfile(String uid);
}
