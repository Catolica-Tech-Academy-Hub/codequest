import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:codequest/features/block_assembly/domain/entities/logic_block.dart';

/// Estado do assembly board (tabuleiro de montagem).
///
/// Camada: presentation/controllers — gerencia estado local de UI.
class AssemblyBoardState {
  const AssemblyBoardState({
    required this.selectedSequence,
    required this.availableBlocks,
    required this.submitting,
    required this.validationErrors,
  });

  /// Sequência de blocos que o usuário selecionou (ordem importa).
  final List<LogicBlock> selectedSequence;

  /// Blocos disponíveis para serem arrastados.
  final List<LogicBlock> availableBlocks;

  /// Se está submetendo a tentativa.
  final bool submitting;

  /// Posições com erro de validação.
  final Set<int> validationErrors;

  /// Cria uma cópia modificada do estado.
  AssemblyBoardState copyWith({
    List<LogicBlock>? selectedSequence,
    List<LogicBlock>? availableBlocks,
    bool? submitting,
    Set<int>? validationErrors,
  }) {
    return AssemblyBoardState(
      selectedSequence: selectedSequence ?? this.selectedSequence,
      availableBlocks: availableBlocks ?? this.availableBlocks,
      submitting: submitting ?? this.submitting,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }

  /// Se a sequência está completa.
  bool get isSequenceFull =>
      selectedSequence.length == availableBlocks.length;

  /// Índice do primeiro erro (-1 se nenhum).
  int get firstErrorIndex =>
      validationErrors.isEmpty ? -1 : validationErrors.first;
}

/// Controlador para o tabuleiro de montagem usando Riverpod.
///
/// Camada: presentation/controllers — orquestra mudanças de estado local.
final assemblyBoardProvider =
    StateNotifierProvider<AssemblyBoardNotifier, AssemblyBoardState>((ref) {
  return AssemblyBoardNotifier();
});

class AssemblyBoardNotifier extends StateNotifier<AssemblyBoardState> {
  AssemblyBoardNotifier()
      : super(
          const AssemblyBoardState(
            selectedSequence: [],
            availableBlocks: [],
            submitting: false,
            validationErrors: {},
          ),
        );

  /// Inicializa o tabuleiro com blocos disponíveis.
  void initializeBlocks(List<LogicBlock> blocks) {
    state = state.copyWith(
      availableBlocks: [...blocks],
      selectedSequence: [],
      validationErrors: {},
    );
  }

  /// Adiciona um bloco na posição especificada.
  void addBlockAtPosition(int position, LogicBlock block) {
    if (position < 0 || position > state.selectedSequence.length) return;

    final newSequence = [...state.selectedSequence];
    newSequence.insert(position, block);

    // Remove erros quando usuário corrige
    state = state.copyWith(
      selectedSequence: newSequence,
      validationErrors: {},
    );
  }

  /// Remove o bloco na posição especificada.
  void removeBlockAtPosition(int position) {
    if (position < 0 || position >= state.selectedSequence.length) return;

    final newSequence = [...state.selectedSequence];
    newSequence.removeAt(position);

    state = state.copyWith(
      selectedSequence: newSequence,
      validationErrors: {},
    );
  }

  /// Move um bloco de uma posição para outra.
  void moveBlock(int fromPosition, int toPosition) {
    if (fromPosition < 0 ||
        fromPosition >= state.selectedSequence.length ||
        toPosition < 0 ||
        toPosition > state.selectedSequence.length) {
      return;
    }

    final newSequence = [...state.selectedSequence];
    final block = newSequence.removeAt(fromPosition);
    newSequence.insert(toPosition, block);

    state = state.copyWith(
      selectedSequence: newSequence,
      validationErrors: {},
    );
  }

  /// Limpa a sequência selecionada (reset).
  void clearSequence() {
    state = state.copyWith(
      selectedSequence: [],
      validationErrors: {},
    );
  }

  /// Define estado de submissão.
  void setSubmitting(bool submitting) {
    state = state.copyWith(submitting: submitting);
  }

  /// Marca erros de validação.
  void setValidationErrors(Set<int> errorPositions) {
    state = state.copyWith(validationErrors: errorPositions);
  }

  /// Limpa erros de validação.
  void clearValidationErrors() {
    state = state.copyWith(validationErrors: {});
  }
}
