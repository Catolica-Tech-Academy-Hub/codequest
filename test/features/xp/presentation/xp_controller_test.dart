import 'package:codequest/features/levels/domain/entities/level.dart';
import 'package:codequest/features/levels/domain/entities/level_result.dart';
import 'package:codequest/features/levels/domain/value_objects/answer_key.dart';
import 'package:codequest/features/xp/application/actions/award_xp_action.dart';
import 'package:codequest/features/xp/domain/entities/xp_grant.dart';
import 'package:codequest/features/xp/domain/entities/xp_state.dart';
import 'package:codequest/features/xp/domain/repositories/xp_repository_contract.dart';
import 'package:codequest/features/xp/presentation/controllers/xp_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingXpRepository implements XpRepositoryContract {
  int commits = 0;

  @override
  Future<XpState> fetchState(String userId) async => const XpState.initial();

  @override
  Future<bool> commitLevelCompletion({
    required String userId,
    required String levelId,
    required XpGrant grant,
  }) async {
    commits++;
    return true;
  }
}

XpController _controllerWith(_RecordingXpRepository repository) {
  return XpController(
    awardXpAction: AwardXpAction(
      repository: repository,
      clock: () => DateTime(2026, 6, 14),
    ),
    readUserId: () => 'user-1',
  );
}

final _oneChoice = OneChoiceLevel(
  id: 'level_1',
  question: 'Q?',
  options: <AnswerKey, String>{AnswerKey('a'): 'A', AnswerKey('b'): 'B'},
  correctAnswer: AnswerKey('b'),
);

void main() {
  test('acerto em nível respondível concede XP', () async {
    final repository = _RecordingXpRepository();
    final controller = _controllerWith(repository);

    final result = await controller.awardForLevel(
      level: _oneChoice,
      result: LevelResult(
        correct: true,
        selected: <AnswerKey>{AnswerKey('b')},
        expected: <AnswerKey>{AnswerKey('b')},
      ),
    );

    expect(result?.awarded, isTrue);
    expect(repository.commits, 1);
  });

  test('erro em nível respondível não pontua nem toca a persistência',
      () async {
    final repository = _RecordingXpRepository();
    final controller = _controllerWith(repository);

    final result = await controller.awardForLevel(
      level: _oneChoice,
      result: LevelResult(
        correct: false,
        selected: <AnswerKey>{AnswerKey('a')},
        expected: <AnswerKey>{AnswerKey('b')},
      ),
    );

    expect(result, isNull);
    expect(repository.commits, 0);
  });

  test('nível de conteúdo concede XP de conclusão sem resultado', () async {
    final repository = _RecordingXpRepository();
    final controller = _controllerWith(repository);

    final result = await controller.awardForLevel(
      level: const ContentLevel(id: 'level_0', title: 'T', body: 'B'),
    );

    expect(result?.awarded, isTrue);
    expect(repository.commits, 1);
  });

  test('sem usuário logado não pontua', () async {
    final repository = _RecordingXpRepository();
    final controller = XpController(
      awardXpAction: AwardXpAction(repository: repository),
      readUserId: () => null,
    );

    final result = await controller.awardForLevel(
      level: const ContentLevel(id: 'level_0', title: 'T', body: 'B'),
    );

    expect(result, isNull);
    expect(repository.commits, 0);
  });
}
