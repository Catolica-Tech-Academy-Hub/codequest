import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/sorting_attempt.dart';
import '../../domain/value_objects/line_id.dart';

class SortingAttemptDto {
  const SortingAttemptDto({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.submittedOrder,
    required this.isCorrect,
    required this.attemptNumber,
    required this.createdAt,
    required this.xpEarned,
    required this.feedback,
  });

  final String id;
  final String challengeId;
  final String userId;
  final List<String> submittedOrder;
  final bool isCorrect;
  final int attemptNumber;
  final DateTime createdAt;
  final int xpEarned;
  final String feedback;

  factory SortingAttemptDto.fromFirestore(Map<String, dynamic> map) {
    return SortingAttemptDto(
      id: map['id'] as String,
      challengeId: map['challengeId'] as String,
      userId: map['userId'] as String,
      submittedOrder: List<String>.from(map['submittedOrder'] as List),
      isCorrect: map['isCorrect'] as bool,
      attemptNumber: map['attemptNumber'] as int,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      xpEarned: (map['xpEarned'] as int?) ?? 0,
      feedback: (map['feedback'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'challengeId': challengeId,
        'userId': userId,
        'submittedOrder': submittedOrder,
        'isCorrect': isCorrect,
        'attemptNumber': attemptNumber,
        'createdAt': Timestamp.fromDate(createdAt),
        'xpEarned': xpEarned,
        'feedback': feedback,
      };

  SortingAttempt toDomain() => SortingAttempt(
        id: id,
        challengeId: challengeId,
        userId: userId,
        submittedOrder: submittedOrder.map((s) => LineId(s)).toList(),
        isCorrect: isCorrect,
        attemptNumber: attemptNumber,
        createdAt: createdAt,
        xpEarned: xpEarned,
        feedback: feedback,
      );
}
