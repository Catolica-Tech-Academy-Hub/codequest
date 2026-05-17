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
        activityIds: <String>[
          'activity_0',
          'activity_1',
          'activity_2',
          'activity_3',
          'activity_4',
          'activity_5',
          'activity_6',
        ],
      ),
    ];
  }
}
