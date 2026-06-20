import 'package:codequest/features/auth/domain/repositories/auth_repository_contract.dart';
import 'package:codequest/features/auth/domain/value_objects/email_address.dart';

class SendPasswordResetAction {
  SendPasswordResetAction(this._repository);

  final AuthRepositoryContract _repository;

  Future<void> call(String email) {
    return _repository.sendPasswordReset(EmailAddress(email));
  }
}
