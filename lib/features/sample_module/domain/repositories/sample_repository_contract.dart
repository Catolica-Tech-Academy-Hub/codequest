import 'package:codequest/features/sample_module/domain/entities/sample_item.dart';

abstract class SampleRepositoryContract {
  Future<SampleItem> create({required String title});
  Stream<List<SampleItem>> watchAll();
}
