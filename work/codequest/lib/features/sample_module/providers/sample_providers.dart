import 'package:codequest/features/sample_module/application/actions/create_sample_action.dart';
import 'package:codequest/features/sample_module/application/actions/watch_samples_action.dart';
import 'package:codequest/features/sample_module/data/repositories/sample_repository_impl.dart';
import 'package:codequest/features/sample_module/domain/entities/sample_item.dart';
import 'package:codequest/features/sample_module/domain/repositories/sample_repository_contract.dart';
import 'package:codequest/features/sample_module/presentation/controllers/sample_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sampleRepositoryProvider = Provider<SampleRepositoryContract>((ref) {
  return SampleRepositoryImpl();
});

final createSampleActionProvider = Provider<CreateSampleAction>((ref) {
  return CreateSampleAction(ref.watch(sampleRepositoryProvider));
});

final watchSamplesActionProvider = Provider<WatchSamplesAction>((ref) {
  return WatchSamplesAction(ref.watch(sampleRepositoryProvider));
});

final sampleControllerProvider = Provider<SampleController>((ref) {
  return SampleController(
    createAction: ref.watch(createSampleActionProvider),
    watchAction: ref.watch(watchSamplesActionProvider),
  );
});

final sampleItemsProvider = StreamProvider<List<SampleItem>>((ref) {
  return ref.watch(sampleControllerProvider).watchItems();
});
