import 'package:equatable/equatable.dart';

/// Representa o progresso de um usuário em uma trilha específica.
class UserTrailProgress extends Equatable {
  const UserTrailProgress({
    required this.userId,
    required this.trailId,
    required this.highestUnlockedLevelIndex,
  });

  final String userId;
  final String trailId;

  /// O índice (na lista levelIds da trilha) do nível mais alto que o usuário tem acesso.
  /// 0 significa que apenas o primeiro nível (índice 0) está desbloqueado.
  final int highestUnlockedLevelIndex;

  @override
  List<Object?> get props => [userId, trailId, highestUnlockedLevelIndex];

  UserTrailProgress copyWith({
    String? userId,
    String? trailId,
    int? highestUnlockedLevelIndex,
  }) {
    return UserTrailProgress(
      userId: userId ?? this.userId,
      trailId: trailId ?? this.trailId,
      highestUnlockedLevelIndex:
          highestUnlockedLevelIndex ?? this.highestUnlockedLevelIndex,
    );
  }
}
