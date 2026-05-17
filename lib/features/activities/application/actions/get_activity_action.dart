import 'package:codequest/features/activities/domain/entities/activity.dart';
import 'package:codequest/features/activities/domain/repositories/activity_repository_contract.dart';

class GetActivityAction {
  GetActivityAction(this._repository);

  final ActivityRepositoryContract _repository;

  Future<Activity> call(String id) {
    return _repository.getById(id);
  }
}
