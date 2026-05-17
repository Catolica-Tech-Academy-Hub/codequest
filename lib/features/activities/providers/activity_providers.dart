import 'package:codequest/features/activities/application/actions/evaluate_activity_action.dart';
import 'package:codequest/features/activities/application/actions/get_activity_action.dart';
import 'package:codequest/features/activities/data/repositories/activity_repository_impl.dart';
import 'package:codequest/features/activities/data/sources/activity_data_source.dart';
import 'package:codequest/features/activities/data/sources/json_asset_activity_data_source.dart';
import 'package:codequest/features/activities/domain/entities/activity.dart';
import 'package:codequest/features/activities/domain/repositories/activity_repository_contract.dart';
import 'package:codequest/features/activities/presentation/controllers/activity_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activityDataSourceProvider = Provider<ActivityDataSource>((ref) {
  return JsonAssetActivityDataSource();
});

final activityRepositoryProvider = Provider<ActivityRepositoryContract>((ref) {
  return ActivityRepositoryImpl(ref.watch(activityDataSourceProvider));
});

final getActivityActionProvider = Provider<GetActivityAction>((ref) {
  return GetActivityAction(ref.watch(activityRepositoryProvider));
});

final evaluateActivityActionProvider = Provider<EvaluateActivityAction>((ref) {
  return const EvaluateActivityAction();
});

final activityControllerProvider = Provider<ActivityController>((ref) {
  return ActivityController(
    getAction: ref.watch(getActivityActionProvider),
    evaluateAction: ref.watch(evaluateActivityActionProvider),
  );
});

final activityByIdProvider = FutureProvider.family<Activity, String>((ref, id) {
  return ref.watch(activityControllerProvider).load(id);
});
