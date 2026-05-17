sealed class TrailFailure implements Exception {
  const TrailFailure();

  factory TrailFailure.notFound(String id) = TrailNotFoundFailure;
}

final class TrailNotFoundFailure extends TrailFailure {
  const TrailNotFoundFailure(this.id);
  final String id;

  @override
  String toString() => 'Trilha não encontrada: "$id".';
}
