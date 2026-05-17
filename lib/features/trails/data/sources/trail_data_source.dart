import 'package:codequest/features/trails/domain/entities/trail.dart';

abstract class TrailDataSource {
  Future<List<Trail>> fetchAll();
}
