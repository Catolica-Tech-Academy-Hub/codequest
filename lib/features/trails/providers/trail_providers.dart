import 'package:codequest/features/auth/providers/auth_providers.dart';
import 'package:codequest/features/trails/application/actions/get_trail_action.dart';
import 'package:codequest/features/trails/application/actions/list_trails_action.dart';
import 'package:codequest/features/trails/application/actions/unlock_next_level_use_case.dart';
import 'package:codequest/features/trails/data/repositories/trail_repository_impl.dart';
import 'package:codequest/features/trails/data/sources/mock_trail_data_source.dart';
import 'package:codequest/features/trails/data/sources/trail_data_source.dart';
import 'package:codequest/features/trails/domain/entities/trail.dart';
import 'package:codequest/features/trails/domain/entities/user_trail_progress.dart';
import 'package:codequest/features/trails/domain/repositories/trail_repository_contract.dart';
import 'package:codequest/features/trails/presentation/controllers/trail_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final trailDataSourceProvider = Provider<TrailDataSource>((ref) {
  return const MockTrailDataSource();
});

final trailRepositoryProvider = Provider<TrailRepositoryContract>((ref) {
  return TrailRepositoryImpl(ref.watch(trailDataSourceProvider));
});

final listTrailsActionProvider = Provider<ListTrailsAction>((ref) {
  return ListTrailsAction(ref.watch(trailRepositoryProvider));
});

final getTrailActionProvider = Provider<GetTrailAction>((ref) {
  return GetTrailAction(ref.watch(trailRepositoryProvider));
});

final trailControllerProvider = Provider<TrailController>((ref) {
  return TrailController(
    listAction: ref.watch(listTrailsActionProvider),
    getAction: ref.watch(getTrailActionProvider),
  );
});

final trailsProvider = FutureProvider<List<Trail>>((ref) {
  return ref.watch(trailControllerProvider).listTrails();
});

final trailByIdProvider = FutureProvider.family<Trail, String>((ref, id) {
  return ref.watch(trailControllerProvider).getTrail(id);
});

final unlockNextLevelUseCaseProvider = Provider<UnlockNextLevelUseCase>((ref) {
  return UnlockNextLevelUseCase(ref.watch(trailRepositoryProvider));
});

final userTrailProgressProvider = FutureProvider.family<UserTrailProgress?, String>((ref, trailId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(trailRepositoryProvider).getUserProgress(
        userId: user.uid,
        trailId: trailId,
      );
});
