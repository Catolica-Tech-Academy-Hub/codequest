import 'package:codequest/features/sample_module/application/actions/create_sample_action.dart';
import 'package:codequest/features/sample_module/application/actions/watch_samples_action.dart';
import 'package:codequest/features/sample_module/domain/entities/sample_item.dart';

class SampleController {
  SampleController({
    required CreateSampleAction createAction,
    required WatchSamplesAction watchAction,
  })  : _createAction = createAction,
        _watchAction = watchAction;

  final CreateSampleAction _createAction;
  final WatchSamplesAction _watchAction;

  Future<SampleItem> createItem(String title) {
    return _createAction.call(title);
  }

  Stream<List<SampleItem>> watchItems() {
    return _watchAction.call();
  }
}
