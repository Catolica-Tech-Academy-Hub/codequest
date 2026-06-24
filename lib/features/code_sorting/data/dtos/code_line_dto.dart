import '../../domain/entities/code_line.dart';
import '../../domain/value_objects/line_id.dart';

class CodeLineDto {
  const CodeLineDto({
    required this.id,
    required this.content,
    required this.expectedPosition,
    required this.indentLevel,
  });

  final String id;
  final String content;
  final int expectedPosition;
  final int indentLevel;

  factory CodeLineDto.fromMap(Map<String, dynamic> map) {
    return CodeLineDto(
      id: map['id'] as String,
      content: map['content'] as String,
      expectedPosition: map['expectedPosition'] as int,
      indentLevel: (map['indentLevel'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'content': content,
        'expectedPosition': expectedPosition,
        'indentLevel': indentLevel,
      };

  CodeLine toDomain() => CodeLine(
        id: LineId(id),
        content: content,
        expectedPosition: expectedPosition,
        indentLevel: indentLevel,
      );
}
