import 'package:codequest/features/code_sorting/domain/entities/code_sorting_challenge.dart';
import 'package:codequest/features/code_sorting/data/dtos/code_line_dto.dart';

class CodeSortingChallengeDto {
  const CodeSortingChallengeDto({
    required this.id,
    required this.title,
    required this.description,
    required this.lines,
    required this.xpReward,
    required this.maxAttempts,
    required this.language,
    required this.difficulty,
  });

  final String id;
  final String title;
  final String description;
  final List<CodeLineDto> lines;
  final int xpReward;
  final int maxAttempts;
  final String language;
  final String difficulty;

  factory CodeSortingChallengeDto.fromFirestore(Map<String, dynamic> map) {
    final rawLines = (map['lines'] as List<dynamic>? ?? []);
    return CodeSortingChallengeDto(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      lines: rawLines
          .map((l) => CodeLineDto.fromMap(l as Map<String, dynamic>))
          .toList(),
      xpReward: (map['xpReward'] as int?) ?? 100,
      maxAttempts: (map['maxAttempts'] as int?) ?? 3,
      language: (map['language'] as String?) ?? 'dart',
      difficulty: (map['difficulty'] as String?) ?? 'medium',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'title': title,
        'description': description,
        'lines': lines.map((l) => l.toMap()).toList(),
        'xpReward': xpReward,
        'maxAttempts': maxAttempts,
        'language': language,
        'difficulty': difficulty,
      };

  CodeSortingChallenge toDomain() => CodeSortingChallenge(
        id: id,
        title: title,
        description: description,
        lines: lines.map((l) => l.toDomain()).toList()
          ..sort((a, b) => a.expectedPosition.compareTo(b.expectedPosition)),
        xpReward: xpReward,
        maxAttempts: maxAttempts,
        language: language,
        difficulty: difficulty,
      );
}
