import 'package:codequest/features/trails/data/sources/trail_data_source.dart';
import 'package:codequest/features/trails/domain/entities/trail.dart';
import 'package:codequest/features/trails/domain/errors/trail_failure.dart';
import 'package:codequest/features/trails/domain/repositories/trail_repository_contract.dart';

class TrailRepositoryImpl implements TrailRepositoryContract {
  TrailRepositoryImpl(this._dataSource);

  final TrailDataSource _dataSource;

  @override
  Future<List<Trail>> listAll() => _dataSource.fetchAll();

  @override
  Future<Trail> getById(String id) async {
    final trails = await _dataSource.fetchAll();
    for (final trail in trails) {
      if (trail.id == id) return trail;
    }
    throw TrailFailure.notFound(id);
  }
}
