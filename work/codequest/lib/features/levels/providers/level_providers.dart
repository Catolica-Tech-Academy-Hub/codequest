import 'package:codequest/features/levels/application/actions/build_level_completion_summary_action.dart';
import 'package:codequest/features/levels/application/actions/evaluate_level_action.dart';
import 'package:codequest/features/levels/application/actions/get_level_action.dart';
import 'package:codequest/features/levels/data/repositories/level_repository_impl.dart';
import 'package:codequest/features/levels/data/sources/level_data_source.dart';
import 'package:codequest/features/levels/data/sources/json_asset_level_data_source.dart';
import 'package:codequest/features/levels/domain/entities/level.dart';
import 'package:codequest/features/levels/domain/repositories/level_repository_contract.dart';
import 'package:codequest/features/levels/presentation/controllers/level_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final levelDataSourceProvider = Provider<LevelDataSource>((ref) {
  return JsonAssetLevelDataSource();
});

final levelRepositoryProvider = Provider<LevelRepositoryContract>((ref) {
  return LevelRepositoryImpl(ref.watch(levelDataSourceProvider));
});

final getLevelActionProvider = Provider<GetLevelAction>((ref) {
  return GetLevelAction(ref.watch(levelRepositoryProvider));
});

final evaluateLevelActionProvider = Provider<EvaluateLevelAction>((ref) {
  return const EvaluateLevelAction();
});

final buildLevelCompletionSummaryActionProvider =
    Provider<BuildLevelCompletionSummaryAction>((ref) {
  return const BuildLevelCompletionSummaryAction();
});

final levelControllerProvider = Provider<LevelController>((ref) {
  return LevelController(
    getAction: ref.watch(getLevelActionProvider),
    evaluateAction: ref.watch(evaluateLevelActionProvider),
    buildCompletionSummaryAction: ref.watch(
      buildLevelCompletionSummaryActionProvider,
    ),
  );
});

final levelByIdProvider = FutureProvider.family<Level, String>((ref, id) {
  return ref.watch(levelControllerProvider).load(id);
});
