import 'package:codequest/features/sample_module/domain/entities/sample_item.dart';
import 'package:codequest/features/sample_module/domain/repositories/sample_repository_contract.dart';

class WatchSamplesAction {
  WatchSamplesAction(this._repository);

  final SampleRepositoryContract _repository;

  Stream<List<SampleItem>> call() {
    return _repository.watchAll();
  }
}
