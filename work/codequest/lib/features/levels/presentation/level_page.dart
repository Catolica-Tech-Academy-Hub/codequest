import 'package:codequest/features/levels/domain/entities/level_completion_summary.dart';
import 'package:codequest/features/levels/presentation/level_builder.dart';
import 'package:codequest/features/levels/presentation/level_completion_page.dart';
import 'package:codequest/features/levels/providers/level_providers.dart';
import 'package:codequest/features/trails/providers/trail_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LevelPage extends ConsumerStatefulWidget {
  const LevelPage({
    required this.levelId,
    this.trailId,
    super.key,
  });

  final String levelId;
  final String? trailId;

  @override
  ConsumerState<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends ConsumerState<LevelPage> {
  LevelCompletionSummary? _completionSummary;

  void _continue(BuildContext context) {
    final trail = widget.trailId;
    if (trail != null && trail.isNotEmpty) {
      context.go('/trail/$trail');
    } else {
      context.go('/home/trails');
    }
  }

  Future<void> _goToNextLesson(BuildContext context) async {
    final trailId = widget.trailId;
    if (trailId == null || trailId.isEmpty) {
      _continue(context);
      return;
    }

    final trail = await ref.read(trailByIdProvider(trailId).future);
    if (!context.mounted) return;

    final currentIndex = trail.levelIds.indexOf(widget.levelId);
    final nextIndex = currentIndex + 1;
    if (currentIndex >= 0 && nextIndex < trail.levelIds.length) {
      context.go('/level/${trail.levelIds[nextIndex]}?trailId=${trail.id}');
      return;
    }

    _continue(context);
  }

  void _showCompletion(LevelCompletionSummary summary) {
    setState(() => _completionSummary = summary);
  }

  @override
  void didUpdateWidget(covariant LevelPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.levelId != widget.levelId) {
      _completionSummary = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(levelByIdProvider(widget.levelId));
    final completionSummary = _completionSummary;

    return Scaffold(
      appBar: AppBar(title: const Text('Nivel')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: completionSummary != null
              ? LevelCompletionPage(
                  summary: completionSummary,
                  onNextLesson: () {
                    _goToNextLesson(context);
                  },
                )
              : state.when(
                  data: (level) => SingleChildScrollView(
                    child: LevelBuilder(
                      level: level,
                      onCompleted: _showCompletion,
                    ),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
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
