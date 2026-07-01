class AuthFailure implements Exception {
  const AuthFailure({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;

  factory AuthFailure.invalidEmail() {
    return const AuthFailure(
      code: 'invalid-email',
      message: 'Informe um e-mail valido.',
    );
  }

  factory AuthFailure.invalidPasswordPolicy() {
    return const AuthFailure(
      code: 'invalid-password-policy',
      message: 'A senha deve ter no minimo 8 caracteres, com letra e numero.',
    );
  }

  factory AuthFailure.invalidDisplayName() {
    return const AuthFailure(
      code: 'invalid-display-name',
      message: 'Nome deve ter entre 2 e 50 caracteres.',
    );
  }

  factory AuthFailure.userNotFound() {
    return const AuthFailure(
      code: 'user-not-found',
      message: 'Usuario nao encontrado.',
    );
  }

  factory AuthFailure.invalidCredentials() {
    return const AuthFailure(
      code: 'invalid-credentials',
      message: 'Credenciais invalidas.',
    );
  }

  factory AuthFailure.emailAlreadyInUse() {
    return const AuthFailure(
      code: 'email-already-in-use',
      message: 'Este e-mail ja esta em uso.',
    );
  }

  factory AuthFailure.tooManyRequests() {
    return const AuthFailure(
      code: 'too-many-requests',
      message: 'Muitas tentativas. Tente novamente em instantes.',
    );
  }

  factory AuthFailure.operationNotAllowed() {
    return const AuthFailure(
      code: 'operation-not-allowed',
      message: 'Operacao de autenticacao nao permitida.',
    );
  }

  factory AuthFailure.weakPassword() {
    return const AuthFailure(
      code: 'weak-password',
      message: 'Senha fraca. Use uma senha mais forte.',
    );
  }

  factory AuthFailure.requiresRecentLogin() {
    return const AuthFailure(
      code: 'requires-recent-login',
      message: 'Por seguranca, faca login novamente antes de continuar.',
    );
  }

  factory AuthFailure.passwordMismatch() {
    return const AuthFailure(
      code: 'password-mismatch',
      message: 'As senhas nao coincidem.',
    );
  }

  factory AuthFailure.invalidBio() {
    return const AuthFailure(
      code: 'invalid-bio',
      message: 'O recado deve ter no maximo 160 caracteres.',
    );
  }

  factory AuthFailure.unexpected() {
    return const AuthFailure(
      code: 'unexpected-auth-error',
      message: 'Erro inesperado de autenticacao.',
    );
  }

  @override
  String toString() {
    return 'AuthFailure(code: $code, message: $message)';
  }
}
