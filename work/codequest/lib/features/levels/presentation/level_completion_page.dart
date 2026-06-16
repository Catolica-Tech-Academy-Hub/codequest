import 'package:codequest/features/levels/domain/entities/level_completion_summary.dart';
import 'package:flutter/material.dart';

class LevelCompletionPage extends StatefulWidget {
  const LevelCompletionPage({
    required this.summary,
    required this.onNextLesson,
    super.key,
  });

  final LevelCompletionSummary summary;
  final VoidCallback onNextLesson;

  @override
  State<LevelCompletionPage> createState() => _LevelCompletionPageState();
}

class _LevelCompletionPageState extends State<LevelCompletionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.7, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = widget.summary;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: _CompletionMark(success: summary.completedWithSuccess),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            summary.completedWithSuccess
                ? 'Nivel concluido!'
                : 'Nivel finalizado',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary.completedWithSuccess
                ? 'Mandou bem. Sua sequencia continua subindo.'
                : 'Revise a resposta correta e tente manter a proxima sequencia.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _XpPanel(xpEarned: summary.xpEarned),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _MetricTile(
                  icon: Icons.check_circle_outline,
                  label: 'Acertos',
                  value: summary.correctAnswers.toString(),
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  icon: Icons.highlight_off,
                  label: 'Erros',
                  value: summary.wrongAnswers.toString(),
                  color: const Color(0xFFC62828),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StreakPanel(summary: summary),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: widget.onNextLesson,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Proxima licao'),
          ),
        ],
      ),
    );
  }
}

class _CompletionMark extends StatelessWidget {
  const _CompletionMark({required this.success});

  final bool success;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = success ? const Color(0xFF2E7D32) : theme.colorScheme.primary;
    return Center(
      child: Container(
        width: 128,
        height: 128,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.28), width: 2),
        ),
        child: Icon(
          success ? Icons.workspace_premium : Icons.flag_circle,
          color: color,
          size: 72,
        ),
      ),
    );
  }
}

class _XpPanel extends StatelessWidget {
  const _XpPanel({required this.xpEarned});

  final int xpEarned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.bolt,
            color: theme.colorScheme.onPrimaryContainer,
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'XP ganho',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '+$xpEarned',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 108),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakPanel extends StatelessWidget {
  const _StreakPanel({required this.summary});

  final LevelCompletionSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = summary.streakIncreased
        ? const Color(0xFFFF8F00)
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.local_fire_department, color: color, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Streak atualizado',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary.streakIncreased
                      ? '${summary.previousStreak} -> ${summary.currentStreak} dias'
                      : 'Sequencia reiniciada',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            summary.currentStreak.toString(),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
