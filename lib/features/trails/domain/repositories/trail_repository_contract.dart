import 'package:codequest/features/trails/domain/entities/trail.dart';

abstract class TrailRepositoryContract {
  Future<List<Trail>> listAll();
  Future<Trail> getById(String id);
}
