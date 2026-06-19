import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:codequest/features/code_sorting/domain/entities/code_line.dart';
import 'package:codequest/features/code_sorting/domain/entities/code_sorting_challenge.dart';
import 'package:codequest/features/code_sorting/domain/value_objects/line_id.dart';
import 'package:codequest/features/code_sorting/presentation/controllers/sorting_board_controller.dart';
import 'package:codequest/features/code_sorting/presentation/widgets/sortable_code_line.dart';
import 'package:codequest/features/code_sorting/presentation/widgets/sorting_feedback_widgets.dart';
import 'package:codequest/features/code_sorting/application/actions/validate_sorting_use_case.dart';

/// Tela de preview com dados mock — apenas para desenvolvimento local.
/// Não requer Firestore nem autenticação.
class CodeSortingPreviewPage extends ConsumerStatefulWidget {
  const CodeSortingPreviewPage({super.key});

  @override
  ConsumerState<CodeSortingPreviewPage> createState() =>
      _CodeSortingPreviewPageState();
}

class _CodeSortingPreviewPageState
    extends ConsumerState<CodeSortingPreviewPage> {
  static final _mockChallenge = CodeSortingChallenge(
    id: 'preview',
    title: 'Função de Fibonacci',
    description: 'Ordene as linhas para montar a função que calcula Fibonacci recursivamente.',
    language: 'dart',
    difficulty: 'medium',
    xpReward: 120,
    maxAttempts: 3,
    lines: const [
      CodeLine(id: LineId('l1'), content: 'int fibonacci(int n) {', expectedPosition: 0),
      CodeLine(id: LineId('l2'), content: '  if (n <= 1) return n;', expectedPosition: 1, indentLevel: 1),
      CodeLine(id: LineId('l3'), content: '  return fibonacci(n - 1) + fibonacci(n - 2);', expectedPosition: 2, indentLevel: 1),
      CodeLine(id: LineId('l4'), content: '}', expectedPosition: 3),
    ],
  );

  int _attemptCount = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(sortingBoardProvider.notifier).initializeLines(_mockChallenge.lines);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final boardState = ref.watch(sortingBoardProvider);

    final expectedOrder = [..._mockChallenge.lines]
      ..sort((a, b) => a.expectedPosition.compareTo(b.expectedPosition));
    final correctCount = boardState.correctCount(expectedOrder);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Ordenação de Código',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'PREVIEW',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _mockChallenge.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _mockChallenge.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _chip(context, 'DART', Icons.code_rounded, theme.colorScheme.primary),
                    _chip(context, 'MÉDIO', null, Colors.orange),
                    _chip(context, '+120 XP', Icons.bolt, theme.colorScheme.primary),
                  ],
                ),
                const SizedBox(height: 16),
                SortingProgressIndicator(
                  correctCount: correctCount,
                  totalCount: _mockChallenge.lineCount,
                ),
                const SizedBox(height: 8),
                RemainingAttemptsIndicator(
                  used: _attemptCount,
                  max: _mockChallenge.maxAttempts,
                ),
                const SizedBox(height: 12),
                Text(
                  'Arraste as linhas para ordenar o código:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(
            child: boardState.lines.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: boardState.lines.length,
                    onReorder: (oldIndex, newIndex) {
                      ref
                          .read(sortingBoardProvider.notifier)
                          .reorderLine(oldIndex, newIndex);
                    },
                    proxyDecorator: (child, index, animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          final elev =
                              Tween<double>(begin: 0, end: 8).evaluate(animation);
                          return Material(
                            elevation: elev,
                            borderRadius: BorderRadius.circular(10),
                            child: child,
                          );
                        },
                        child: child,
                      );
                    },
                    itemBuilder: (context, index) {
                      final line = boardState.lines[index];
                      final hasError = boardState.errorIndices.contains(index);
                      final isCorrect = boardState.errorIndices.isEmpty &&
                          index < expectedOrder.length &&
                          line.id == expectedOrder[index].id;
                      return SortableCodeLine(
                        key: ValueKey(line.id.value),
                        line: line,
                        index: index,
                        hasError: hasError,
                        isCorrect: isCorrect,
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: boardState.submitting
                          ? null
                          : () => ref
                              .read(sortingBoardProvider.notifier)
                              .resetOrder(_mockChallenge.lines),
                      icon: const Icon(Icons.shuffle_rounded, size: 18),
                      label: const Text('Embaralhar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: boardState.submitting ? null : _handleVerify,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Verificar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleVerify() {
    final boardState = ref.read(sortingBoardProvider);
    setState(() => _attemptCount++);

    final result = const ValidateSortingUseCase().call(
      challenge: _mockChallenge,
      submittedOrder: boardState.lines.map((l) => LineId(l.id.value)).toList(),
      attemptNumber: _attemptCount,
    );

    if (result.isCorrect) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: SortingSuccessOverlay(
            xpEarned: result.xpEarned,
            onDismiss: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    } else {
      final expectedOrder = [..._mockChallenge.lines]
        ..sort((a, b) => a.expectedPosition.compareTo(b.expectedPosition));
      final errors = <int>{};
      for (int i = 0; i < boardState.lines.length; i++) {
        if (i >= expectedOrder.length ||
            boardState.lines[i].id != expectedOrder[i].id) {
          errors.add(i);
        }
      }
      ref.read(sortingBoardProvider.notifier).setErrorIndices(errors);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.feedback),
          duration: const Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _chip(BuildContext context, String label, IconData? icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
