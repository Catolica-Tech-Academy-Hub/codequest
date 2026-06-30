import 'package:codequest/features/auth/domain/errors/auth_failure.dart';
import 'package:codequest/features/auth/domain/repositories/auth_repository_contract.dart';
import 'package:codequest/features/auth/domain/repositories/user_profile_repository_contract.dart';
import 'package:codequest/features/auth/domain/value_objects/display_name.dart';

class UpdateProfileAction {
  UpdateProfileAction(this._authRepository, this._profileRepository);

  final AuthRepositoryContract _authRepository;
  final UserProfileRepositoryContract _profileRepository;

  Future<void> call({
    required String uid,
    required String name,
    String? bio,
  }) async {
    final resolvedName = DisplayName(name);

    if (bio != null && bio.length > 160) {
      throw AuthFailure.invalidBio();
    }

    final resolvedBio = (bio?.trim().isEmpty ?? true) ? null : bio?.trim();

    await _profileRepository.updateProfile(
      uid: uid,
      name: resolvedName.value,
      bio: resolvedBio,
    );
    await _authRepository.updateDisplayName(displayName: resolvedName);
  }
}
