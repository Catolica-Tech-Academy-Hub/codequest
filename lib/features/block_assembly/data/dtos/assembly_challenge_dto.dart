import '../../domain/entities/assembly_challenge.dart';
import 'logic_block_dto.dart';

/// DTO que mapeia um desafio de montagem do Firestore para entidade de domínio.
///
/// Camada: data — serialização e mapeamento de dados externos.
///
/// Campos esperados no Firestore:
///   id          : String
///   title       : String
///   description : String
///   blocks      : List<Map> (array de blocos)
///   xpReward    : int
///   maxAttempts : int
///   difficulty  : String (opcional, padrão 'medium')
class AssemblyChallengeDto {
  const AssemblyChallengeDto({
    required this.id,
    required this.title,
    required this.description,
    required this.blocks,
    required this.xpReward,
    required this.maxAttempts,
    this.difficulty = 'medium',
  });

  final String id;
  final String title;
  final String description;
  final List<LogicBlockDto> blocks;
  final int xpReward;
  final int maxAttempts;
  final String difficulty;

  /// Converte DTO para entidade de domínio.
  AssemblyChallenge toDomain() {
    return AssemblyChallenge(
      id: id,
      title: title,
      description: description,
      blocks: blocks.map((b) => b.toDomain()).toList(),
      xpReward: xpReward,
      maxAttempts: maxAttempts,
      difficulty: difficulty,
    );
  }

  /// Cria DTO a partir de Map (Firestore doc).
  factory AssemblyChallengeDto.fromFirestore(Map<String, dynamic> data) {
    final blocksList = (data['blocks'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    return AssemblyChallengeDto(
      id: (data['id'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      blocks: blocksList.map((b) => LogicBlockDto.fromFirestore(b)).toList(),
      xpReward: (data['xpReward'] as int?) ?? 0,
      maxAttempts: (data['maxAttempts'] as int?) ?? 3,
      difficulty: (data['difficulty'] as String?) ?? 'medium',
    );
  }

  /// Converte DTO para Map para salvar no Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'blocks': blocks.map((b) => b.toFirestore()).toList(),
      'xpReward': xpReward,
      'maxAttempts': maxAttempts,
      'difficulty': difficulty,
    };
  }
}
