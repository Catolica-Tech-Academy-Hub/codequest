import 'package:codequest/features/levels/domain/entities/level.dart';

abstract class LevelRepositoryContract {
  Future<Level> getById(String id);
}
