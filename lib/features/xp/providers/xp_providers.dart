import 'package:codequest/features/auth/providers/auth_providers.dart';
import 'package:codequest/features/xp/application/actions/award_xp_action.dart';
import 'package:codequest/features/xp/data/repositories/firestore_xp_repository.dart';
import 'package:codequest/features/xp/domain/repositories/xp_repository_contract.dart';
import 'package:codequest/features/xp/domain/services/xp_calculator.dart';
import 'package:codequest/features/xp/presentation/controllers/xp_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final xpRepositoryProvider = Provider<XpRepositoryContract>((ref) {
  return FirestoreXpRepository();
});

final xpCalculatorProvider = Provider<XpCalculator>((ref) {
  return const XpCalculator();
});

final awardXpActionProvider = Provider<AwardXpAction>((ref) {
  return AwardXpAction(
    repository: ref.watch(xpRepositoryProvider),
    calculator: ref.watch(xpCalculatorProvider),
  );
});

final xpControllerProvider = Provider<XpController>((ref) {
  return XpController(
    awardXpAction: ref.watch(awardXpActionProvider),
    readUserId: () => ref.read(currentUserProvider)?.uid,
  );
});
