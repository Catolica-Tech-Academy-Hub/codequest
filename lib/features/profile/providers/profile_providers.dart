import 'package:codequest/features/auth/domain/entities/user_profile.dart';
import 'package:codequest/features/auth/providers/auth_providers.dart';
import 'package:codequest/features/profile/application/actions/profile_use_case.dart';
import 'package:codequest/features/profile/data/repositories/profile_repository.dart';
import 'package:codequest/features/profile/domain/repositories/profile_repository_contract.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Camada de dados
// ---------------------------------------------------------------------------

/// Provider do repositório concreto, exposto pelo contrato (DIP).
final profileRepositoryProvider = Provider<ProfileRepositoryContract>((ref) {
  return ProfileRepository();
});

// ---------------------------------------------------------------------------
// Camada de aplicação
// ---------------------------------------------------------------------------

/// Provider do caso de uso, recebendo o repositório por injeção.
final profileUseCaseProvider = Provider<ProfileUseCase>((ref) {
  return ProfileUseCase(ref.watch(profileRepositoryProvider));
});

// ---------------------------------------------------------------------------
// Camada de estado (consumido pela UI)
// ---------------------------------------------------------------------------

/// Gerencia o estado assíncrono do perfil do usuário logado.
///
/// Carrega automaticamente o perfil a partir do [currentUserProvider]
/// e expõe um método [updateSettings] para atualizar as configurações.
final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, UserProfile?>(ProfileNotifier.new);

class ProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      return null;
    }

    final useCase = ref.read(profileUseCaseProvider);
    return useCase.getProfile(currentUser.uid);
  }

  /// Atualiza as configurações do usuário e recarrega o estado.
  Future<void> updateSettings(Map<String, dynamic> settings) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      throw StateError('Nenhum usuário autenticado para atualizar settings.');
    }

    final useCase = ref.read(profileUseCaseProvider);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => useCase.updateSettings(currentUser.uid, settings),
    );
  }
}
