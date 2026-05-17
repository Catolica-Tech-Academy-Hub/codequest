import 'package:codequest/features/activities/domain/entities/activity.dart';

abstract class ActivityRepositoryContract {
  Future<Activity> getById(String id);
}
