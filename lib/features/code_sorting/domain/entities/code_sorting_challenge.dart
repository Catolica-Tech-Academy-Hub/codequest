import 'package:equatable/equatable.dart';

import 'package:codequest/features/code_sorting/domain/entities/code_line.dart';

/// Entidade que representa um desafio de ordenação de código.
///
/// Camada: domain — sem dependências externas.
class CodeSortingChallenge extends Equatable {
  const CodeSortingChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.lines,
    required this.xpReward,
    required this.maxAttempts,
    this.language = 'dart',
    this.difficulty = 'medium',
  });

  final String id;
  final String title;
  final String description;

  /// Linhas de código que compõem este desafio (em ordem correta).
  final List<CodeLine> lines;

  final int xpReward;
  final int maxAttempts;

  /// Linguagem de programação para highlight visual (ex: 'dart', 'python').
  final String language;

  /// Nível de dificuldade: 'easy', 'medium', 'hard'.
  final String difficulty;

  int get lineCount => lines.length;

  @override
  List<Object?> get props =>
      [id, title, description, lines, xpReward, maxAttempts, language, difficulty];

  @override
  String toString() =>
      'CodeSortingChallenge(id: $id, title: $title, lines: $lineCount)';
}
