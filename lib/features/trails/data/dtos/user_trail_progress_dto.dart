import 'package:codequest/features/trails/domain/entities/user_trail_progress.dart';

class UserTrailProgressDto {
  const UserTrailProgressDto({
    required this.userId,
    required this.trailId,
    required this.highestUnlockedLevelIndex,
  });

  final String userId;
  final String trailId;
  final int highestUnlockedLevelIndex;

  factory UserTrailProgressDto.fromDomain(UserTrailProgress domain) {
    return UserTrailProgressDto(
      userId: domain.userId,
      trailId: domain.trailId,
      highestUnlockedLevelIndex: domain.highestUnlockedLevelIndex,
    );
  }

  factory UserTrailProgressDto.fromFirestore(Map<String, dynamic> data) {
    return UserTrailProgressDto(
      userId: data['userId'] as String? ?? '',
      trailId: data['trailId'] as String? ?? '',
      highestUnlockedLevelIndex: data['highestUnlockedLevelIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'trailId': trailId,
      'highestUnlockedLevelIndex': highestUnlockedLevelIndex,
    };
  }

  UserTrailProgress toDomain() {
    return UserTrailProgress(
      userId: userId,
      trailId: trailId,
      highestUnlockedLevelIndex: highestUnlockedLevelIndex,
    );
  }
}
