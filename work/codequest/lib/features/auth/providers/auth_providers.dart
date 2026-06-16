import 'package:codequest/features/auth/application/actions/observe_auth_state_action.dart';
import 'package:codequest/features/auth/application/actions/send_password_reset_action.dart';
import 'package:codequest/features/auth/application/actions/sign_in_action.dart';
import 'package:codequest/features/auth/application/actions/sign_out_action.dart';
import 'package:codequest/features/auth/application/actions/sign_up_action.dart';
import 'package:codequest/features/auth/data/auth_repository.dart';
import 'package:codequest/features/auth/data/user_profile_repository.dart';
import 'package:codequest/features/auth/domain/entities/auth_user.dart';
import 'package:codequest/features/auth/domain/repositories/auth_repository_contract.dart';
import 'package:codequest/features/auth/domain/repositories/user_profile_repository_contract.dart';
import 'package:codequest/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepositoryContract>((ref) {
  return AuthRepository();
});

final userProfileRepositoryProvider = Provider<UserProfileRepositoryContract>((ref) {
  return UserProfileRepository();
});

final observeAuthStateActionProvider = Provider<ObserveAuthStateAction>((ref) {
  return ObserveAuthStateAction(ref.watch(authRepositoryProvider));
});

final signInActionProvider = Provider<SignInAction>((ref) {
  return SignInAction(ref.watch(authRepositoryProvider));
});

final signUpActionProvider = Provider<SignUpAction>((ref) {
  return SignUpAction(
    ref.watch(authRepositoryProvider),
    ref.watch(userProfileRepositoryProvider),
  );
});

final signOutActionProvider = Provider<SignOutAction>((ref) {
  return SignOutAction(ref.watch(authRepositoryProvider));
});

final sendPasswordResetActionProvider = Provider<SendPasswordResetAction>((ref) {
  return SendPasswordResetAction(ref.watch(authRepositoryProvider));
});

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(
    signInAction: ref.watch(signInActionProvider),
    signUpAction: ref.watch(signUpActionProvider),
    signOutAction: ref.watch(signOutActionProvider),
    sendPasswordResetAction: ref.watch(sendPasswordResetActionProvider),
  );
});

final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(observeAuthStateActionProvider).call();
});

final currentUserProvider = Provider<AuthUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value;
});
