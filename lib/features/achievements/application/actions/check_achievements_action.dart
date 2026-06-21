import 'package:codequest/features/achievements/domain/entities/achievement.dart';
import 'package:codequest/features/achievements/domain/repositories/achievements_repository_contract.dart';

class CheckAchievementsAction {
  CheckAchievementsAction(this._repository);

  final AchievementsRepositoryContract _repository;

  Future<List<Achievement>> call() {
    return _repository.check();
  }
}
