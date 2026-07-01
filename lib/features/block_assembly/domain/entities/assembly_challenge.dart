import 'package:equatable/equatable.dart';

import 'package:codequest/features/block_assembly/domain/entities/logic_block.dart';

/// Entidade que representa um desafio de montagem lógica.
///
/// Camada: domain — sem dependências externas.
///
/// Um desafio contém um conjunto de blocos que devem ser organizados
/// na sequência correta para montar uma estrutura lógica válida.
class AssemblyChallenge extends Equatable {
  const AssemblyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.blocks,
    required this.xpReward,
    required this.maxAttempts,
    this.difficulty = 'medium',
  });

  /// Identificador único do desafio.
  final String id;

  /// Título/nome do desafio.
  final String title;

  /// Descrição/contexto do desafio.
  final String description;

  /// Lista de blocos que compõem este desafio.
  final List<LogicBlock> blocks;

  /// Recompensa de XP ao completar corretamente.
  final int xpReward;

  /// Número máximo de tentativas permitidas.
  final int maxAttempts;

  /// Nível de dificuldade: 'easy', 'medium', 'hard'.
  final String difficulty;

  /// Número total de blocos no desafio.
  int get blockCount => blocks.length;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    blocks,
    xpReward,
    maxAttempts,
    difficulty,
  ];

  @override
  String toString() =>
      'AssemblyChallenge(id: $id, title: $title, blocks: $blockCount)';
}
