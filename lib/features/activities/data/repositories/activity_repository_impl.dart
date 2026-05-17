import 'package:codequest/features/activities/data/dtos/activity_dto.dart';
import 'package:codequest/features/activities/data/sources/activity_data_source.dart';
import 'package:codequest/features/activities/domain/entities/activity.dart';
import 'package:codequest/features/activities/domain/repositories/activity_repository_contract.dart';

class ActivityRepositoryImpl implements ActivityRepositoryContract {
  ActivityRepositoryImpl(this._dataSource);

  final ActivityDataSource _dataSource;

  @override
  Future<Activity> getById(String id) async {
    final raw = await _dataSource.fetchRaw(id);
    return ActivityDto(id: id, raw: raw).toDomain();
  }
}
