import 'package:codequest/features/trails/presentation/widgets/activity_node.dart';
import 'package:codequest/features/trails/providers/trail_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TrailDetailPage extends ConsumerWidget {
  const TrailDetailPage({required this.trailId, super.key});

  final String trailId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trailByIdProvider(trailId));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(state.valueOrNull?.title ?? 'Trilha'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
          onPressed: () => context.go('/home/trails'),
        ),
      ),
      body: state.when(
        data: (trail) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                trail.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < trail.activityIds.length; i++)
              ActivityNode(
                index: i + 1,
                alignment: Alignment.center,
                onTap: () => context.go(
                  '/activity/${trail.activityIds[i]}?trailId=${trail.id}',
                ),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}
