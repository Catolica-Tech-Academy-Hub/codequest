import 'package:codequest/features/levels/domain/entities/level.dart';
import 'package:codequest/features/levels/domain/repositories/level_repository_contract.dart';

class GetLevelAction {
  GetLevelAction(this._repository);

  final LevelRepositoryContract _repository;

  Future<Level> call(String id) {
    return _repository.getById(id);
  }
}
