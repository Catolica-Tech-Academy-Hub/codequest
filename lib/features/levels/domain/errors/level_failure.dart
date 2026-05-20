sealed class LevelFailure implements Exception {
  const LevelFailure();

  factory LevelFailure.invalidAnswerKey(String raw) = InvalidAnswerKeyFailure;
  factory LevelFailure.unknownType(String type) = UnknownLevelTypeFailure;
  factory LevelFailure.malformedLevel(String reason) = MalformedLevelFailure;
  factory LevelFailure.notFound(String id) = LevelNotFoundFailure;
}

final class InvalidAnswerKeyFailure extends LevelFailure {
  const InvalidAnswerKeyFailure(this.raw);
  final String raw;

  @override
  String toString() => 'Chave de resposta inválida: "$raw" (esperado: única letra a-z).';
}

final class UnknownLevelTypeFailure extends LevelFailure {
  const UnknownLevelTypeFailure(this.type);
  final String type;

  @override
  String toString() => 'Tipo de nível desconhecido: "$type".';
}

final class MalformedLevelFailure extends LevelFailure {
  const MalformedLevelFailure(this.reason);
  final String reason;

  @override
  String toString() => 'Nível malformado: $reason.';
}

final class LevelNotFoundFailure extends LevelFailure {
  const LevelNotFoundFailure(this.id);
  final String id;

  @override
  String toString() => 'Nível não encontrado: "$id".';
}
