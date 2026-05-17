import 'package:codequest/features/trails/presentation/widgets/trail_card.dart';
import 'package:codequest/features/trails/providers/trail_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TrailsPage extends ConsumerWidget {
  const TrailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trailsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Trilhas')),
      body: state.when(
        data: (trails) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: trails.length,
          itemBuilder: (context, index) {
            final trail = trails[index];
            return TrailCard(
              trail: trail,
              onTap: () => context.go('/trail/${trail.id}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}
