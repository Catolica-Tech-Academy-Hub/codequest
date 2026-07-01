import 'package:codequest/features/auth/domain/entities/auth_user.dart';
import 'package:codequest/features/auth/domain/errors/auth_failure.dart';
import 'package:codequest/features/auth/domain/repositories/auth_repository_contract.dart';
import 'package:codequest/features/auth/domain/value_objects/display_name.dart';
import 'package:codequest/features/auth/domain/value_objects/email_address.dart';
import 'package:codequest/features/auth/domain/value_objects/password.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository implements AuthRepositoryContract {
  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Stream<AuthUser?> get authStateChanges async* {
    yield _mapFirebaseUser(_auth.currentUser);
    yield* _auth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  Future<AuthUser> signIn({required EmailAddress email, required Password password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.value,
        password: password.value,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthFailure.userNotFound();
      }

      return _mapFirebaseUser(user)!;
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<AuthUser> signUp({
    required EmailAddress email,
    required Password password,
    required DisplayName name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.value,
        password: password.value,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthFailure.unexpected();
      }

      await user.updateDisplayName(name.value);

      return _mapFirebaseUser(user)!;
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  @override
  Future<void> sendPasswordReset(EmailAddress email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.value);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<void> reauthenticate({
    required EmailAddress email,
    required Password password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw AuthFailure.userNotFound();
    final credential = EmailAuthProvider.credential(
      email: email.value,
      password: password.value,
    );
    try {
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<void> updatePassword({required Password newPassword}) async {
    final user = _auth.currentUser;
    if (user == null) throw AuthFailure.userNotFound();
    try {
      await user.updatePassword(newPassword.value);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<void> updateDisplayName({required DisplayName displayName}) async {
    final user = _auth.currentUser;
    if (user == null) throw AuthFailure.userNotFound();
    await user.updateDisplayName(displayName.value);
  }

  @override
  Future<void> deleteCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) throw AuthFailure.userNotFound();
    try {
      await user.delete();
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  AuthUser? _mapFirebaseUser(User? user) {
    if (user == null) {
      return null;
    }

    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  AuthFailure _mapFirebaseAuthException(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return AuthFailure.invalidEmail();
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return AuthFailure.invalidCredentials();
      case 'email-already-in-use':
        return AuthFailure.emailAlreadyInUse();
      case 'too-many-requests':
        return AuthFailure.tooManyRequests();
      case 'operation-not-allowed':
        return AuthFailure.operationNotAllowed();
      case 'weak-password':
        return AuthFailure.weakPassword();
      case 'requires-recent-login':
        return AuthFailure.requiresRecentLogin();
      default:
        return AuthFailure.unexpected();
    }
  }
}
