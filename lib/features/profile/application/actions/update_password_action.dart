import 'package:codequest/features/auth/domain/errors/auth_failure.dart';
import 'package:codequest/features/auth/domain/repositories/auth_repository_contract.dart';
import 'package:codequest/features/auth/domain/value_objects/email_address.dart';
import 'package:codequest/features/auth/domain/value_objects/password.dart';

class UpdatePasswordAction {
  UpdatePasswordAction(this._authRepository);

  final AuthRepositoryContract _authRepository;

  Future<void> call({
    required String email,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      throw AuthFailure.passwordMismatch();
    }

    final resolvedEmail = EmailAddress(email);
    final resolvedCurrent = Password(currentPassword);
    final resolvedNew = Password(newPassword);

    await _authRepository.reauthenticate(
      email: resolvedEmail,
      password: resolvedCurrent,
    );
    await _authRepository.updatePassword(newPassword: resolvedNew);
  }
}
