import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/assembly_challenge.dart';
import '../../domain/entities/logic_block.dart';
import '../../domain/value_objects/block_id.dart';
import '../controllers/assembly_board_controller.dart';
import '../widgets/draggable_logic_block.dart';
import '../widgets/drop_zone.dart';
import '../widgets/feedback_widgets.dart';
import '../../providers/block_assembly_providers.dart';

/// Tela principal do desafio de montagem lógica por blocos.
///
/// Camada: presentation — renderiza UI e dispara ações via providers.
///
/// Fluxo:
/// 1. Carrega desafio e progresso do usuário
/// 2. Permite arrastar blocos para posições
/// 3. Submete tentativa quando usuario clica "Enviar"
/// 4. Exibe feedback + XP ganho
class BlockAssemblyPage extends ConsumerStatefulWidget {
  const BlockAssemblyPage({
    super.key,
    required this.challengeId,
    required this.userId,
  });

  final String challengeId;
  final String userId;

  @override
  ConsumerState<BlockAssemblyPage> createState() =>
      _BlockAssemblyPageState();
}

class _BlockAssemblyPageState extends ConsumerState<BlockAssemblyPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pageAnimationController;
  FeedbackOverlay? _lastFeedback;

  @override
  void initState() {
    super.initState();
    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pageAnimationController.forward();
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challengeAsync = ref.watch(
      blockAssemblyChallengeProvider(widget.challengeId),
    );
    final progressAsync = ref.watch(
      userChallengeProgressProvider(
        (userId: widget.userId, challengeId: widget.challengeId),
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context),
      body: challengeAsync.when(
        loading: () => const _LoadingState(),
        error: (error, _) => _ErrorState(message: error.toString()),
        data: (challenge) {
          return _ChallengeBody(
            challenge: challenge,
            userId: widget.userId,
            pageAnimationController: _pageAnimationController,
            onFeedbackDismiss: () {
              setState(() => _lastFeedback = null);
            },
          );
        },
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
        'Desafio de Montagem',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
      centerTitle: true,
    );
  }
}

// ============================================================================
// Corpo do desafio
// ============================================================================

class _ChallengeBody extends ConsumerStatefulWidget {
  const _ChallengeBody({
    required this.challenge,
    required this.userId,
    required this.pageAnimationController,
    required this.onFeedbackDismiss,
  });

  final AssemblyChallenge challenge;
  final String userId;
  final AnimationController pageAnimationController;
  final VoidCallback onFeedbackDismiss;

  @override
  ConsumerState<_ChallengeBody> createState() => _ChallengeBodyState();
}

class _ChallengeBodyState extends ConsumerState<_ChallengeBody> {
  @override
  void initState() {
    super.initState();
    // Inicializa o board com os blocos do desafio
    ref.read(assemblyBoardProvider.notifier)
        .initializeBlocks(widget.challenge.blocks);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final boardState = ref.watch(assemblyBoardProvider);
    final progressAsync = ref.watch(
      userChallengeProgressProvider(
        (userId: widget.userId, challengeId: widget.challengeId),
      ),
    );
    final submitUseCase = ref.watch(submitAssemblyAttemptUseCaseProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do desafio
          _ChallengeHeader(challenge: widget.challenge),
          const SizedBox(height: 24),

          // Descrição
          Text(
            widget.challenge.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Blocos disponíveis (fonte)
          Text(
            'Blocos Disponíveis',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _BlocksSource(
            blocks: widget.challenge.blocks,
            selectedIds: {
              for (final b in boardState.selectedSequence) b.id.value
            },
          ),
          const SizedBox(height: 32),

          // Áreas de destino
          Text(
            'Monte a Sequência Correta',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _DropZonesRow(
            challenge: widget.challenge,
            selectedSequence: boardState.selectedSequence,
            validationErrors: boardState.validationErrors,
          ),
          const SizedBox(height: 24),

          // Tentativas restantes
          progressAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (progress) => progress != null
                ? RemainingAttemptsWidget(
                    current: progress.attemptCount,
                    max: widget.challenge.maxAttempts,
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),

          // Feedback de validação
          if (boardState.validationErrors.isNotEmpty)
            ValidationErrorWidget(
              errorPositions: boardState.validationErrors,
              totalPositions: widget.challenge.blockCount,
            ),

          const SizedBox(height: 24),

          // Botões de ação
          _ActionButtons(
            isSubmitting: boardState.submitting,
            isSequenceFull: boardState.isSequenceFull,
            onSubmit: () => _handleSubmit(context, submitUseCase),
            onReset: () {
              ref.read(assemblyBoardProvider.notifier).clearSequence();
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    dynamic submitUseCase,
  ) async {
    final boardState = ref.read(assemblyBoardProvider);

    if (!boardState.isSequenceFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todas as posições antes de enviar.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    ref.read(assemblyBoardProvider.notifier).setSubmitting(true);

    try {
      final result = await submitUseCase.call(
        challenge: widget.challenge,
        userId: widget.userId,
        selectedSequence: boardState.selectedSequence
            .map((b) => BlockId(b.id.value))
            .toList(),
      );

      if (mounted) {
        // Exibir feedback
        if (result.isSuccess) {
          _showSuccessFeedback(context, result.feedback, result.xpEarned);
          // Aguardar feedback e voltar
          await Future.delayed(const Duration(seconds: 3));
          if (mounted) Navigator.of(context).pop();
        } else {
          _showErrorFeedback(context, result.feedback);
          ref.read(assemblyBoardProvider.notifier).clearSequence();
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorFeedback(context, 'Erro: $e');
      }
    } finally {
      ref.read(assemblyBoardProvider.notifier).setSubmitting(false);
    }
  }

  void _showSuccessFeedback(
    BuildContext context,
    String message,
    int xpEarned,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: FeedbackOverlay(
          isSuccess: true,
          message: message,
          xpEarned: xpEarned,
          onDismiss: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _showErrorFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

// ============================================================================
// Widgets auxiliares
// ============================================================================

class _ChallengeHeader extends StatelessWidget {
  const _ChallengeHeader({required this.challenge});
  final AssemblyChallenge challenge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color difficultyColor;
    switch (challenge.difficulty) {
      case 'easy':
        difficultyColor = Colors.green;
        break;
      case 'medium':
        difficultyColor = Colors.orange;
        break;
      case 'hard':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = colorScheme.primary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          challenge.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: difficultyColor.withOpacity(0.2),
                border: Border.all(color: difficultyColor),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                challenge.difficulty.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: difficultyColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.2),
                border: Border.all(color: colorScheme.primary),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '+${challenge.xpReward} XP',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BlocksSource extends StatelessWidget {
  const _BlocksSource({
    required this.blocks,
    required this.selectedIds,
  });

  final List<LogicBlock> blocks;
  final Set<String> selectedIds;

  @override
  Widget build(BuildContext context) {
    final availableBlocks =
        blocks.where((b) => !selectedIds.contains(b.id.value)).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableBlocks
          .map(
            (block) => DraggableLogicBlock(
              block: block,
              isSelected: false,
            ),
          )
          .toList(),
    );
  }
}

class _DropZonesRow extends ConsumerWidget {
  const _DropZonesRow({
    required this.challenge,
    required this.selectedSequence,
    required this.validationErrors,
  });

  final AssemblyChallenge challenge;
  final List<LogicBlock> selectedSequence;
  final Set<int> validationErrors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: List.generate(
        challenge.blocks.length,
        (index) {
          final expectedBlock = challenge.blocks[index];
          final currentBlock =
              index < selectedSequence.length ? selectedSequence[index] : null;
          final hasError = validationErrors.contains(index);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DropZone(
              position: index + 1,
              expectedBlock: expectedBlock,
              currentBlock: currentBlock,
              isHighlighted: currentBlock != null,
              hasError: hasError,
              onAccept: (block) {
                ref
                    .read(assemblyBoardProvider.notifier)
                    .addBlockAtPosition(index, block);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isSubmitting,
    required this.isSequenceFull,
    required this.onSubmit,
    required this.onReset,
  });

  final bool isSubmitting;
  final bool isSequenceFull;
  final VoidCallback onSubmit;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSubmitting ? null : onReset,
            child: const Text('Limpar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: isSubmitting || !isSequenceFull ? null : onSubmit,
            icon: isSubmitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(colorScheme.onPrimary),
                    ),
                  )
                : const Icon(Icons.check),
            label: Text(isSubmitting ? 'Enviando...' : 'Enviar'),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Estados de carregamento e erro
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
