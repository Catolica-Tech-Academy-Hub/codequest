/// Hierarquia de erros do domínio de ordenação de código.
///
/// Camada: domain — sem dependências externas.
sealed class CodeSortingError implements Exception {
  const CodeSortingError(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class ChallengeNotFoundError extends CodeSortingError {
  const ChallengeNotFoundError(super.message);
}

class InvalidOrderError extends CodeSortingError {
  const InvalidOrderError(super.message);
}

class RepositoryError extends CodeSortingError {
  const RepositoryError(super.message);
}
