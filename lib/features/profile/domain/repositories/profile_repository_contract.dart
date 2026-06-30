import 'package:codequest/features/auth/domain/entities/user_profile.dart';

/// Contrato de acesso a dados do perfil do usuário.
///
/// Define as operações de leitura e atualização de perfil disponíveis
/// para as camadas superiores (application / presentation).
///
/// Implementações concretas vivem em `data/` e podem usar Firestore,
/// REST, cache local, etc.
abstract class ProfileRepositoryContract {
  /// Busca o perfil completo de um usuário pelo seu [uid].
  ///
  /// Retorna `null` caso o documento não exista.
  Future<UserProfile?> getProfile(String uid);

  /// Atualiza somente o mapa de configurações do usuário identificado
  /// por [uid].
  ///
  /// A implementação deve fazer merge parcial para não sobrescrever
  /// outros campos do documento.
  Future<void> updateSettings(String uid, Map<String, dynamic> settings);
}
