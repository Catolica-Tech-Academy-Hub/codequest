import 'package:codequest/features/auth/domain/repositories/auth_repository_contract.dart';
import 'package:codequest/features/auth/domain/repositories/user_profile_repository_contract.dart';

class DeleteAccountAction {
  DeleteAccountAction(this._authRepository, this._profileRepository);

  final AuthRepositoryContract _authRepository;
  final UserProfileRepositoryContract _profileRepository;

  Future<void> call({required String uid}) async {
    // Deleta Firestore antes de Auth (ainda autenticado)
    await _profileRepository.deleteProfile(uid);
    await _authRepository.deleteCurrentUser();
  }
}
