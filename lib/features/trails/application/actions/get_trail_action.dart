import 'package:codequest/features/trails/domain/entities/trail.dart';
import 'package:codequest/features/trails/domain/repositories/trail_repository_contract.dart';

class GetTrailAction {
  GetTrailAction(this._repository);

  final TrailRepositoryContract _repository;

  Future<Trail> call(String id) {
    return _repository.getById(id);
  }
}
