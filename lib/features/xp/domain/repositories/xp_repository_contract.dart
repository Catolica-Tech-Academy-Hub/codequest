import 'package:codequest/features/xp/domain/entities/xp_grant.dart';
import 'package:codequest/features/xp/domain/entities/xp_state.dart';

abstract interface class XpRepositoryContract {
  Future<XpState> fetchState(String userId);

  Future<bool> commitLevelCompletion({
    required String userId,
    required String levelId,
    required XpGrant grant,
  });
}
