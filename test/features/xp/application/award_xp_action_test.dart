import 'package:codequest/features/xp/application/actions/award_xp_action.dart';
import 'package:codequest/features/xp/domain/entities/task_kind.dart';
import 'package:codequest/features/xp/domain/entities/task_outcome.dart';
import 'package:codequest/features/xp/domain/entities/xp_grant.dart';
import 'package:codequest/features/xp/domain/entities/xp_state.dart';
import 'package:codequest/features/xp/domain/repositories/xp_repository_contract.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeXpRepository implements XpRepositoryContract {
  _FakeXpRepository(this._state);

  XpState _state;
  final Set<String> _completedLevels = <String>{};

  XpGrant? lastGrant;
  String? lastUserId;
  String? lastLevelId;

  @override
  Future<XpState> fetchState(String userId) async => _state;

  @override
  Future<bool> commitLevelCompletion({
    required String userId,
    required String levelId,
    required XpGrant grant,
  }) async {
    lastUserId = userId;
    lastLevelId = levelId;
    lastGrant = grant;

    if (_completedLevels.contains(levelId)) {
      return false;
    }
    _completedLevels.add(levelId);
    _state = XpState(
      xpTotal: _state.xpTotal + grant.totalXp,
      streakDays: grant.streakDays,
      lastActivityDate: grant.awardedAt,
    );
    return true;
  }
}

void main() {
  test('lê o estado, calcula e persiste o ganho na primeira conclusão',
      () async {
    final repository = _FakeXpRepository(
      XpState(
        xpTotal: 100,
        streakDays: 2,
        lastActivityDate: DateTime(2026, 6, 13),
      ),
    );
    final action = AwardXpAction(
      repository: repository,
      clock: () => DateTime(2026, 6, 14, 9),
    );

    final attribution = await action(
      userId: 'user-1',
      levelId: 'level_1',
      outcome: const TaskOutcome(kind: TaskKind.oneChoice),
    );

    expect(attribution.awarded, isTrue);
    expect(repository.lastUserId, 'user-1');
    expect(repository.lastLevelId, 'level_1');
    expect(attribution.grant, repository.lastGrant);
    expect(attribution.grant!.streakDays, 3,
        reason: 'dia seguinte incrementa a ofensiva');
    expect(attribution.grant!.totalXp, greaterThan(0));
    expect(repository._state.xpTotal, 100 + attribution.grant!.totalXp);
  });

  test('não concede XP ao refazer um nível já concluído (anti-replay)',
      () async {
    final repository = _FakeXpRepository(const XpState.initial());
    final action = AwardXpAction(
      repository: repository,
      clock: () => DateTime(2026, 6, 14, 9),
    );

    final first = await action(
      userId: 'user-1',
      levelId: 'level_1',
      outcome: const TaskOutcome(kind: TaskKind.oneChoice),
    );
    final xpAfterFirst = repository._state.xpTotal;

    final second = await action(
      userId: 'user-1',
      levelId: 'level_1',
      outcome: const TaskOutcome(kind: TaskKind.oneChoice),
    );

    expect(first.awarded, isTrue);
    expect(second.awarded, isFalse);
    expect(second.grant, isNull);
    expect(repository._state.xpTotal, xpAfterFirst,
        reason: 'replay não altera o acumulado');
  });

  test('usa o relógio injetado como momento do ganho', () async {
    final fixedNow = DateTime(2026, 1, 1, 8, 30);
    final repository = _FakeXpRepository(const XpState.initial());
    final action = AwardXpAction(repository: repository, clock: () => fixedNow);

    final attribution = await action(
      userId: 'user-1',
      levelId: 'level_0',
      outcome: const TaskOutcome(kind: TaskKind.content),
    );

    expect(attribution.grant!.awardedAt, fixedNow);
  });
}
