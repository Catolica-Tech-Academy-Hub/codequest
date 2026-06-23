import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_sorting_progress.dart';

class UserSortingProgressDto {
  const UserSortingProgressDto({
    required this.userId,
    required this.challengeId,
    required this.isCompleted,
    required this.attemptCount,
    required this.totalXpEarned,
    required this.lastAttemptAt,
    this.firstCompletedAt,
  });

  final String userId;
  final String challengeId;
  final bool isCompleted;
  final int attemptCount;
  final int totalXpEarned;
  final DateTime lastAttemptAt;
  final DateTime? firstCompletedAt;

  factory UserSortingProgressDto.fromFirestore(Map<String, dynamic> map) {
    return UserSortingProgressDto(
      userId: map['userId'] as String,
      challengeId: map['challengeId'] as String,
      isCompleted: (map['isCompleted'] as bool?) ?? false,
      attemptCount: (map['attemptCount'] as int?) ?? 0,
      totalXpEarned: (map['totalXpEarned'] as int?) ?? 0,
      lastAttemptAt:
          (map['lastAttemptAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      firstCompletedAt:
          (map['firstCompletedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'challengeId': challengeId,
        'isCompleted': isCompleted,
        'attemptCount': attemptCount,
        'totalXpEarned': totalXpEarned,
        'lastAttemptAt': Timestamp.fromDate(lastAttemptAt),
        if (firstCompletedAt != null)
          'firstCompletedAt': Timestamp.fromDate(firstCompletedAt!),
      };

  UserSortingProgress toDomain() => UserSortingProgress(
        userId: userId,
        challengeId: challengeId,
        isCompleted: isCompleted,
        attemptCount: attemptCount,
        totalXpEarned: totalXpEarned,
        lastAttemptAt: lastAttemptAt,
        firstCompletedAt: firstCompletedAt,
      );
}
