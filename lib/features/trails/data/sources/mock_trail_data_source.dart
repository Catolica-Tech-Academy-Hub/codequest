import 'package:codequest/features/trails/data/sources/trail_data_source.dart';
import 'package:codequest/features/trails/domain/entities/trail.dart';

class MockTrailDataSource implements TrailDataSource {
  const MockTrailDataSource();

  @override
  Future<List<Trail>> fetchAll() async {
    return const <Trail>[
      Trail(
        id: 'flutter-basico',
        title: 'Flutter Básico',
        description: 'Fundamentos de Flutter e Dart.',
        levelIds: <String>[
          'level_0',
          'level_1',
          'level_2',
          'level_3',
          'level_4',
          'level_5',
          'level_6',
        ],
      ),
    ];
  }
}
