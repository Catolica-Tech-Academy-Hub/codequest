import 'package:codequest/features/auth/domain/entities/auth_user.dart';
import 'package:codequest/features/auth/domain/repositories/auth_repository_contract.dart';

class ObserveAuthStateAction {
  ObserveAuthStateAction(this._repository);

  final AuthRepositoryContract _repository;

  Stream<AuthUser?> call() {
    return _repository.authStateChanges;
  }
}
