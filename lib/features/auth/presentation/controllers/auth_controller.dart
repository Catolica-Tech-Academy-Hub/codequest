import 'package:codequest/features/auth/application/actions/send_password_reset_action.dart';
import 'package:codequest/features/auth/application/actions/sign_in_action.dart';
import 'package:codequest/features/auth/application/actions/sign_out_action.dart';
import 'package:codequest/features/auth/application/actions/sign_up_action.dart';
import 'package:codequest/features/auth/domain/entities/auth_user.dart';

class AuthController {
  AuthController({
    required SignInAction signInAction,
    required SignUpAction signUpAction,
    required SignOutAction signOutAction,
    required SendPasswordResetAction sendPasswordResetAction,
  })  : _signInAction = signInAction,
        _signUpAction = signUpAction,
        _signOutAction = signOutAction,
        _sendPasswordResetAction = sendPasswordResetAction;

  final SignInAction _signInAction;
  final SignUpAction _signUpAction;
  final SignOutAction _signOutAction;
  final SendPasswordResetAction _sendPasswordResetAction;

  Future<AuthUser> signIn({required String email, required String password}) {
    return _signInAction.call(email: email, password: password);
  }

  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String name,
  }) {
    return _signUpAction.call(email: email, password: password, name: name);
  }

  Future<void> signOut() {
    return _signOutAction.call();
  }

  Future<void> sendPasswordReset(String email) {
    return _sendPasswordResetAction.call(email);
  }
}
