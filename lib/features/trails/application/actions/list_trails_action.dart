import 'package:codequest/features/trails/domain/entities/trail.dart';
import 'package:codequest/features/trails/domain/repositories/trail_repository_contract.dart';

class ListTrailsAction {
  ListTrailsAction(this._repository);

  final TrailRepositoryContract _repository;

  Future<List<Trail>> call() {
    return _repository.listAll();
  }
}
