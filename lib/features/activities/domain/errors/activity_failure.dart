sealed class ActivityFailure implements Exception {
  const ActivityFailure();

  factory ActivityFailure.invalidAnswerKey(String raw) = InvalidAnswerKeyFailure;
  factory ActivityFailure.unknownType(String type) = UnknownActivityTypeFailure;
  factory ActivityFailure.malformedActivity(String reason) = MalformedActivityFailure;
  factory ActivityFailure.notFound(String id) = ActivityNotFoundFailure;
}

final class InvalidAnswerKeyFailure extends ActivityFailure {
  const InvalidAnswerKeyFailure(this.raw);
  final String raw;

  @override
  String toString() => 'Chave de resposta inválida: "$raw" (esperado: única letra a-z).';
}

final class UnknownActivityTypeFailure extends ActivityFailure {
  const UnknownActivityTypeFailure(this.type);
  final String type;

  @override
  String toString() => 'Tipo de atividade desconhecido: "$type".';
}

final class MalformedActivityFailure extends ActivityFailure {
  const MalformedActivityFailure(this.reason);
  final String reason;

  @override
  String toString() => 'Atividade malformada: $reason.';
}

final class ActivityNotFoundFailure extends ActivityFailure {
  const ActivityNotFoundFailure(this.id);
  final String id;

  @override
  String toString() => 'Atividade não encontrada: "$id".';
}
