/// Exceção de domínio para desafios de montagem lógica.
///
/// Camada: domain — representa falhas nas regras de negócio.
sealed class BlockAssemblyError implements Exception {
  const BlockAssemblyError(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Bloco solicitado não foi encontrado.
class BlockNotFoundError extends BlockAssemblyError {
  const BlockNotFoundError(String message) : super(message);
}

/// Sequência de blocos inválida ou incompleta.
class InvalidSequenceError extends BlockAssemblyError {
  const InvalidSequenceError(String message) : super(message);
}

/// Limite de tentativas excedido.
class MaxAttemptsExceededError extends BlockAssemblyError {
  const MaxAttemptsExceededError(String message) : super(message);
}

/// Desafio não encontrado ou não está acessível.
class ChallengeNotAccessibleError extends BlockAssemblyError {
  const ChallengeNotAccessibleError(String message) : super(message);
}

/// Falha ao salvar resultado no repositório.
class RepositoryError extends BlockAssemblyError {
  const RepositoryError(String message) : super(message);
}
