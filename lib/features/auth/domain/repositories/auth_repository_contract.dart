import 'package:codequest/features/auth/domain/entities/auth_user.dart';
import 'package:codequest/features/auth/domain/value_objects/display_name.dart';
import 'package:codequest/features/auth/domain/value_objects/email_address.dart';
import 'package:codequest/features/auth/domain/value_objects/password.dart';

abstract class AuthRepositoryContract {
  Stream<AuthUser?> get authStateChanges;

  Future<AuthUser> signIn({
    required EmailAddress email,
    required Password password,
  });

  Future<AuthUser> signUp({
    required EmailAddress email,
    required Password password,
    required DisplayName name,
  });

  Future<void> signOut();

  Future<void> sendPasswordReset(EmailAddress email);
}
