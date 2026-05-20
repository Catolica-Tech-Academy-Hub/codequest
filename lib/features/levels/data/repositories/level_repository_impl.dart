import 'package:codequest/features/levels/data/dtos/level_dto.dart';
import 'package:codequest/features/levels/data/sources/level_data_source.dart';
import 'package:codequest/features/levels/domain/entities/level.dart';
import 'package:codequest/features/levels/domain/repositories/level_repository_contract.dart';

class LevelRepositoryImpl implements LevelRepositoryContract {
  LevelRepositoryImpl(this._dataSource);

  final LevelDataSource _dataSource;

  @override
  Future<Level> getById(String id) async {
    final raw = await _dataSource.fetchRaw(id);
    return LevelDto(id: id, raw: raw).toDomain();
  }
}
