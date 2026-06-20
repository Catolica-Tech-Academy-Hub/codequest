import 'package:codequest/features/sample_module/domain/entities/sample_item.dart';
import 'package:codequest/features/sample_module/domain/repositories/sample_repository_contract.dart';

class CreateSampleAction {
  CreateSampleAction(this._repository);

  final SampleRepositoryContract _repository;

  Future<SampleItem> call(String title) {
    if (title.trim().isEmpty) {
      throw ArgumentError('Título não pode ser vazio.');
    }
    return _repository.create(title: title.trim());
  }
}
