import '../entities/user_achievement.dart';
import '../repositories/achievement_repository.dart';

/// Caso de uso: busca todas as conquistas de um usuário.
class GetAchievementsUseCase {
  final AchievementRepository _repository;

  const GetAchievementsUseCase(this._repository);

  Future<List<UserAchievement>> call(String userId) {
    return _repository.getAchievements(userId);
  }

  Stream<List<UserAchievement>> watch(String userId) {
    return _repository.watchAchievements(userId);
  }
}
