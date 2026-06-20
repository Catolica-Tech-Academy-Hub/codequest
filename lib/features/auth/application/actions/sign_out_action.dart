import 'package:codequest/features/auth/domain/repositories/auth_repository_contract.dart';

class SignOutAction {
  SignOutAction(this._repository);

  final AuthRepositoryContract _repository;

  Future<void> call() {
    return _repository.signOut();
  }
}
