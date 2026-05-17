import 'package:codequest/features/activities/presentation/activity_builder.dart';
import 'package:codequest/features/activities/providers/activity_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ActivityPage extends ConsumerWidget {
  const ActivityPage({
    required this.activityId,
    this.trailId,
    super.key,
  });

  final String activityId;
  final String? trailId;

  void _continue(BuildContext context) {
    final trail = trailId;
    if (trail != null && trail.isNotEmpty) {
      context.go('/trail/$trail');
    } else {
      context.go('/home/trails');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activityByIdProvider(activityId));

    return Scaffold(
      appBar: AppBar(title: const Text('Atividade')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: state.when(
            data: (activity) => SingleChildScrollView(
              child: ActivityBuilder(
                activity: activity,
                onContinue: () => _continue(context),
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
                    onPressed: () => _continue(context),
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
