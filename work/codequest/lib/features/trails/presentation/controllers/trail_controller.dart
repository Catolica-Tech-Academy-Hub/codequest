import 'package:codequest/features/trails/application/actions/get_trail_action.dart';
import 'package:codequest/features/trails/application/actions/list_trails_action.dart';
import 'package:codequest/features/trails/domain/entities/trail.dart';

class TrailController {
  TrailController({
    required ListTrailsAction listAction,
    required GetTrailAction getAction,
  })  : _listAction = listAction,
        _getAction = getAction;

  final ListTrailsAction _listAction;
  final GetTrailAction _getAction;

  Future<List<Trail>> listTrails() => _listAction.call();

  Future<Trail> getTrail(String id) => _getAction.call(id);
}
