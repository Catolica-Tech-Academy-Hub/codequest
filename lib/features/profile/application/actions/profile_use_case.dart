import 'package:codequest/features/auth/domain/entities/user_profile.dart';
import 'package:codequest/features/profile/domain/repositories/profile_repository_contract.dart';

/// Caso de uso que orquestra operações de perfil do usuário.
///
/// Depende exclusivamente do contrato [ProfileRepositoryContract] (DIP).
/// Não contém imports de Flutter, Firebase ou qualquer detalhe de UI/infra.
class ProfileUseCase {
  ProfileUseCase(this._repository);

  final ProfileRepositoryContract _repository;

  /// Busca o perfil completo do usuário identificado por [uid].
  ///
  /// Lança [ProfileNotFoundException] caso o perfil não exista.
  Future<UserProfile> getProfile(String uid) async {
    final profile = await _repository.getProfile(uid);
    if (profile == null) {
      throw ProfileNotFoundException(uid);
    }
    return profile;
  }

  /// Atualiza as configurações do usuário identificado por [uid].
  ///
  /// Retorna o perfil atualizado após a persistência, garantindo que
  /// o chamador receba o estado mais recente.
  Future<UserProfile> updateSettings(
    String uid,
    Map<String, dynamic> settings,
  ) async {
    await _repository.updateSettings(uid, settings);
    return getProfile(uid);
  }
}

/// Exceção lançada quando um perfil não é encontrado no repositório.
class ProfileNotFoundException implements Exception {
  ProfileNotFoundException(this.uid);

  final String uid;

  @override
  String toString() => 'ProfileNotFoundException: perfil não encontrado para uid=$uid';
}
