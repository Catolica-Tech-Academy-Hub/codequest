import 'package:codequest/features/trails/domain/entities/trail.dart';
import 'package:codequest/features/trails/presentation/trail_visuals.dart';
import 'package:codequest/features/trails/presentation/widgets/level_node.dart';
import 'package:codequest/features/trails/providers/trail_providers.dart';
import 'package:codequest/shared/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TrailDetailPage extends ConsumerWidget {
  const TrailDetailPage({required this.trailId, super.key});

  final String trailId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trailByIdProvider(trailId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          state.valueOrNull?.title ?? 'Trilha',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Voltar',
          onPressed: () => context.go('/home/trails'),
        ),
      ),
      body: state.when(
        data: (trail) {
          final visual = TrailVisuals.of(trail.id);
          return ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: <Widget>[
              _TrailBanner(trail: trail, visual: visual),
              const SizedBox(height: 8),
              for (var i = 0; i < trail.levelIds.length; i++)
                LevelNode(
                  index: i + 1,
                  alignment: Alignment.center,
                  accent: visual.accent,
                  showConnector: i > 0,
                  onTap: () => context.go(
                    '/level/${trail.levelIds[i]}?trailId=${trail.id}',
                  ),
                ),
            ],
          );
        },
        loading: () => const _DetailLoading(),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('😵', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  'Não foi possível carregar a trilha.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrailBanner extends StatelessWidget {
  const _TrailBanner({required this.trail, required this.visual});

  final Trail trail;
  final TrailVisual visual;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = visual.accent;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, Color.lerp(accent, Colors.black, 0.4)!],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(visual.emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  trail.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            trail.description,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.layers_rounded, color: Colors.white, size: 15),
                const SizedBox(width: 6),
                Text(
                  '${trail.levelIds.length} níveis',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        const ShimmerBox(height: 140, borderRadius: 24),
        const SizedBox(height: 24),
        ...List.generate(
          4,
          (_) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: ShimmerBox(height: 84, width: 84, borderRadius: 42)),
          ),
        ),
      ],
    );
  }
}
