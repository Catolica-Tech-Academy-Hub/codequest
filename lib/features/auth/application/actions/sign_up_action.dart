import 'package:codequest/features/auth/domain/entities/auth_user.dart';
import 'package:codequest/features/auth/domain/entities/user_profile.dart';
import 'package:codequest/features/auth/domain/repositories/auth_repository_contract.dart';
import 'package:codequest/features/auth/domain/repositories/user_profile_repository_contract.dart';
import 'package:codequest/features/auth/domain/value_objects/display_name.dart';
import 'package:codequest/features/auth/domain/value_objects/email_address.dart';
import 'package:codequest/features/auth/domain/value_objects/password.dart';

class SignUpAction {
  SignUpAction(this._authRepository, this._profileRepository);

  final AuthRepositoryContract _authRepository;
  final UserProfileRepositoryContract _profileRepository;

  Future<AuthUser> call({
    required String email,
    required String password,
    required String name,
  }) async {
    final resolvedEmail = EmailAddress(email);
    final resolvedName = DisplayName(name);

    final user = await _authRepository.signUp(
      email: resolvedEmail,
      password: Password(password),
      name: resolvedName,
    );

    await _profileRepository.createProfile(
      UserProfile(
        id: user.uid,
        email: user.email,
        name: resolvedName.value,
        leagueId: 'bronze-001',
        createdAt: DateTime.now(),
      ),
    );

    return user;
  }
}
