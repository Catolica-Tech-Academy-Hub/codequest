import 'package:codequest/features/auth/domain/entities/auth_user.dart';
import 'package:codequest/features/auth/domain/repositories/auth_repository_contract.dart';
import 'package:codequest/features/auth/domain/value_objects/email_address.dart';
import 'package:codequest/features/auth/domain/value_objects/password.dart';

class SignInAction {
  SignInAction(this._repository);

  final AuthRepositoryContract _repository;

  Future<AuthUser> call({required String email, required String password}) {
    return _repository.signIn(
      email: EmailAddress(email),
      password: Password(password),
    );
  }
}
