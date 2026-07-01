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
  const BlockNotFoundError(super.message);
}

/// Sequência de blocos inválida ou incompleta.
class InvalidSequenceError extends BlockAssemblyError {
  const InvalidSequenceError(super.message);
}

/// Limite de tentativas excedido.
class MaxAttemptsExceededError extends BlockAssemblyError {
  const MaxAttemptsExceededError(super.message);
}

/// Desafio não encontrado ou não está acessível.
class ChallengeNotAccessibleError extends BlockAssemblyError {
  const ChallengeNotAccessibleError(super.message);
}

/// Falha ao salvar resultado no repositório.
class RepositoryError extends BlockAssemblyError {
  const RepositoryError(super.message);
}
