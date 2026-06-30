sealed class TrailFailure implements Exception {
  const TrailFailure();

  factory TrailFailure.notFound(String id) = TrailNotFoundFailure;
  factory TrailFailure.unexpected(String message) = TrailUnexpectedFailure;
}

final class TrailNotFoundFailure extends TrailFailure {
  const TrailNotFoundFailure(this.id);
  final String id;

  @override
  String toString() => 'Trilha não encontrada: "$id".';
}

final class TrailUnexpectedFailure extends TrailFailure {
  const TrailUnexpectedFailure(this.message);
  final String message;

  @override
  String toString() => 'Erro inesperado: $message';
}
