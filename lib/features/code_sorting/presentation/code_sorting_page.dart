import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:codequest/features/code_sorting/domain/entities/code_sorting_challenge.dart';
import 'package:codequest/features/code_sorting/domain/value_objects/line_id.dart';
import 'package:codequest/shared/widgets/feedback_modal.dart';
import 'package:codequest/features/code_sorting/providers/code_sorting_providers.dart';
import 'package:codequest/features/code_sorting/presentation/controllers/sorting_board_controller.dart';
import 'package:codequest/features/code_sorting/presentation/widgets/sortable_code_line.dart';
import 'package:codequest/features/code_sorting/presentation/widgets/sorting_feedback_widgets.dart';

/// Tela principal do desafio de ordenação de linhas de código.
///
/// Camada: presentation — renderiza UI e dispara ações via providers.
///
/// Fluxo:
/// 1. Carrega desafio do Firestore
/// 2. Exibe linhas embaralhadas em lista reordenável (drag-and-drop)
/// 3. Indicador de progresso atualiza em tempo real
/// 4. Submete tentativa e exibe feedback de acerto/erro
class CodeSortingPage extends ConsumerStatefulWidget {
  const CodeSortingPage({
    super.key,
    required this.challengeId,
    required this.userId,
  });

  final String challengeId;
  final String userId;

  @override
  ConsumerState<CodeSortingPage> createState() => _CodeSortingPageState();
}

class _CodeSortingPageState extends ConsumerState<CodeSortingPage> {
  @override
  Widget build(BuildContext context) {
    final challengeAsync =
        ref.watch(codeSortingChallengeProvider(widget.challengeId));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context),
      body: challengeAsync.when(
        loading: () => const _LoadingState(),
        error: (e, _) => _ErrorState(message: e.toString()),
        data: (challenge) => _ChallengeBody(
          challenge: challenge,
          userId: widget.userId,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Ordenação de Código',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
      centerTitle: true,
    );
  }
}

// ============================================================================
// Corpo principal do desafio
// ============================================================================

class _ChallengeBody extends ConsumerStatefulWidget {
  const _ChallengeBody({
    required this.challenge,
    required this.userId,
  });

  final CodeSortingChallenge challenge;
  final String userId;

  @override
  ConsumerState<_ChallengeBody> createState() => _ChallengeBodyState();
}

class _ChallengeBodyState extends ConsumerState<_ChallengeBody> {
  @override
  void initState() {
    super.initState();
    // Embaralha as linhas ao inicializar
    Future.microtask(() {
      ref
          .read(sortingBoardProvider.notifier)
          .initializeLines(widget.challenge.lines);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final boardState = ref.watch(sortingBoardProvider);
    final progressAsync = ref.watch(userSortingProgressProvider(
      (userId: widget.userId, challengeId: widget.challenge.id),
    ),);
    final submitUseCase = ref.watch(submitSortingAttemptUseCaseProvider);

    // Ordem correta para calcular progresso visual
    final expectedOrder = [...widget.challenge.lines]
      ..sort((a, b) => a.expectedPosition.compareTo(b.expectedPosition));
    final currentCorrectCount = boardState.correctCount(expectedOrder);

    return Column(
      children: [
        // Cabeçalho com info do desafio e progresso
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChallengeHeader(challenge: widget.challenge),
              const SizedBox(height: 16),
              SortingProgressIndicator(
                correctCount: currentCorrectCount,
                totalCount: widget.challenge.lineCount,
              ),
              const SizedBox(height: 8),
              progressAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (progress) => progress != null
                    ? RemainingAttemptsIndicator(
                        used: progress.attemptCount,
                        max: widget.challenge.maxAttempts,
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),
              Text(
                'Arraste as linhas para ordenar o código corretamente:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),

        // Lista reordenável de linhas de código
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
                        final elevation =
                            Tween<double>(begin: 0, end: 8).evaluate(animation);
                        return Material(
                          elevation: elevation,
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
                    final isCorrect = index < expectedOrder.length &&
                        line.id == expectedOrder[index].id;

                    return SortableCodeLine(
                      key: ValueKey(line.id.value),
                      line: line,
                      index: index,
                      hasError: hasError,
                      isCorrect: boardState.errorIndices.isEmpty && isCorrect,
                    );
                  },
                ),
        ),

        // Barra de ações
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _ActionBar(
              isSubmitting: boardState.submitting,
              onSubmit: () => _handleSubmit(context, submitUseCase),
              onReset: () => ref
                  .read(sortingBoardProvider.notifier)
                  .resetOrder(widget.challenge.lines),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit(BuildContext context, dynamic submitUseCase) async {
    final boardState = ref.read(sortingBoardProvider);
    if (boardState.submitting) return;

    ref.read(sortingBoardProvider.notifier).setSubmitting(true);

    try {
      final result = await submitUseCase.call(
        challenge: widget.challenge,
        userId: widget.userId,
        submittedOrder:
            boardState.lines.map((l) => LineId(l.id.value)).toList(),
      );

      if (!mounted) return;

      if (result.isCorrect) {
        await showFeedbackModal(
          context,
          status: FeedbackStatus.correct,
          message:
              'Você ordenou o código corretamente!\nVocê ganhou +${result.xpEarned} XP!',
          onContinue: () {
            Navigator.of(context).pop();
          },
        );
      } else {
        final expectedOrder = [...widget.challenge.lines]
          ..sort((a, b) => a.expectedPosition.compareTo(b.expectedPosition));
        final errors = <int>{};
        for (int i = 0; i < boardState.lines.length; i++) {
          if (i >= expectedOrder.length ||
              boardState.lines[i].id != expectedOrder[i].id) {
            errors.add(i);
          }
        }
        ref.read(sortingBoardProvider.notifier).setErrorIndices(errors);

        await showFeedbackModal(
          context,
          status: FeedbackStatus.wrong,
          message: result.feedback,
          onContinue: () {},
        );
      }
    } catch (e) {
      if (mounted) {
        await showFeedbackModal(
          context,
          status: FeedbackStatus.wrong,
          message: 'Erro ao enviar: $e',
          onContinue: () {},
        );
      }
    } finally {
      if (mounted) {
        ref.read(sortingBoardProvider.notifier).setSubmitting(false);
      }
    }
  }
}

// ============================================================================
// Widgets auxiliares
// ============================================================================

class _ChallengeHeader extends StatelessWidget {
  const _ChallengeHeader({required this.challenge});
  final CodeSortingChallenge challenge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final difficultyColor = switch (challenge.difficulty) {
      'easy' => Colors.green,
      'hard' => Colors.red,
      _ => Colors.orange,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          challenge.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          challenge.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            _Chip(
              label: challenge.difficulty.toUpperCase(),
              color: difficultyColor,
            ),
            _Chip(
              label: challenge.language.toUpperCase(),
              color: colorScheme.primary,
              icon: Icons.code_rounded,
            ),
            _Chip(
              label: '+${challenge.xpReward} XP',
              color: colorScheme.primary,
              icon: Icons.bolt,
            ),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.5)),
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

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.isSubmitting,
    required this.onSubmit,
    required this.onReset,
  });

  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isSubmitting ? null : onReset,
            icon: const Icon(Icons.shuffle_rounded, size: 18),
            label: const Text('Embaralhar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: isSubmitting ? null : onSubmit,
            icon: isSubmitting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation(colorScheme.onPrimary),
                    ),
                  )
                : const Icon(Icons.check_rounded, size: 18),
            label: Text(isSubmitting ? 'Enviando...' : 'Verificar'),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Estados de loading e erro
// ============================================================================

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Carregando desafio...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Erro ao carregar', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
