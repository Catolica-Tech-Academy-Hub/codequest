import 'package:codequest/features/trails/presentation/widgets/trail_card.dart';
import 'package:codequest/features/trails/providers/trail_providers.dart';
import 'package:codequest/shared/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TrailsPage extends ConsumerWidget {
  const TrailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trailsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🗺️', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              'Trilhas',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      body: state.when(
        data: (trails) {
          if (trails.isEmpty) return const _EmptyTrails();
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: trails.length,
            itemBuilder: (context, index) {
              final trail = trails[index];
              return TrailCard(
                trail: trail,
                onTap: () => context.go('/trail/${trail.id}'),
              );
            },
          );
        },
        loading: () => const _TrailsLoading(),
        error: (error, _) => _TrailsError(message: error.toString()),
      ),
    );
  }
}

class _TrailsLoading extends StatelessWidget {
  const _TrailsLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: List.generate(
        5,
        (_) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: ShimmerBox(height: 92, borderRadius: 20),
        ),
      ),
    );
  }
}

class _EmptyTrails extends StatelessWidget {
  const _EmptyTrails();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🗺️', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(
            'Nenhuma trilha disponível.',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Novas trilhas aparecerão aqui em breve!',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrailsError extends StatelessWidget {
  const _TrailsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😵', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Não foi possível carregar as trilhas.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
