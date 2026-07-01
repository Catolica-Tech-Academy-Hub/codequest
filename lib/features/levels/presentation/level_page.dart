import 'package:codequest/features/achievements/presentation/achievements_feedback.dart';
import 'package:codequest/features/auth/providers/auth_providers.dart';
import 'package:codequest/features/levels/presentation/level_builder.dart';
import 'package:codequest/features/levels/providers/level_providers.dart';
import 'package:codequest/features/trails/providers/trail_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LevelPage extends ConsumerWidget {
  const LevelPage({
    required this.levelId,
    this.trailId,
    super.key,
  });

  final String levelId;
  final String? trailId;

  void _continue(BuildContext context, WidgetRef ref) async {
    final trail = trailId;

    if (trail != null && trail.isNotEmpty) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final trailState = ref.read(trailByIdProvider(trail)).valueOrNull;
        if (trailState != null) {
          final levelIndex = trailState.levelIds.indexOf(levelId);
          if (levelIndex != -1) {
            await ref.read(unlockNextLevelUseCaseProvider).execute(
                  userId: user.uid,
                  trailId: trail,
                  completedLevelIndex: levelIndex,
                );
            ref.invalidate(userTrailProgressProvider(trail));
          }
        }
      }
      if (context.mounted) context.go('/trail/$trail');
    } else {
      context.go('/home/trails');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(levelByIdProvider(levelId));

    return Scaffold(
      appBar: AppBar(title: const Text('Nível')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: state.when(
            data: (level) => SingleChildScrollView(
              child: LevelBuilder(
                level: level,
                onContinue: () async {
                  await triggerAchievementsCheck(ref, context);
                  if (context.mounted) {
                    _continue(context, ref);
                  }
                },
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => _continue(context, ref),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
