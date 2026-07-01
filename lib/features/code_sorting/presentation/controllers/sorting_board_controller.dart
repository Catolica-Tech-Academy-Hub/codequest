import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:codequest/features/code_sorting/domain/entities/code_line.dart';

/// Estado do tabuleiro de ordenação de código.
///
/// Camada: presentation/controllers — gerencia estado local de UI.
class SortingBoardState {
  const SortingBoardState({
    required this.lines,
    required this.submitting,
    required this.errorIndices,
  });

  /// Linhas na ordem atual definida pelo usuário (drag-and-drop).
  final List<CodeLine> lines;

  /// Se está submetendo a tentativa.
  final bool submitting;

  /// Índices com posição incorreta (após validação com erro).
  final Set<int> errorIndices;

  SortingBoardState copyWith({
    List<CodeLine>? lines,
    bool? submitting,
    Set<int>? errorIndices,
  }) {
    return SortingBoardState(
      lines: lines ?? this.lines,
      submitting: submitting ?? this.submitting,
      errorIndices: errorIndices ?? this.errorIndices,
    );
  }

  /// Quantas linhas estão na posição correta.
  int correctCount(List<CodeLine> expectedOrder) {
    int count = 0;
    for (int i = 0; i < lines.length && i < expectedOrder.length; i++) {
      if (lines[i].id == expectedOrder[i].id) count++;
    }
    return count;
  }
}

final sortingBoardProvider =
    StateNotifierProvider<SortingBoardNotifier, SortingBoardState>((ref) {
  return SortingBoardNotifier();
});

class SortingBoardNotifier extends StateNotifier<SortingBoardState> {
  SortingBoardNotifier()
      : super(const SortingBoardState(
          lines: [],
          submitting: false,
          errorIndices: {},
        ),);

  /// Inicializa com as linhas embaralhadas.
  void initializeLines(List<CodeLine> lines) {
    final shuffled = [...lines]..shuffle();
    state = SortingBoardState(
      lines: shuffled,
      submitting: false,
      errorIndices: {},
    );
  }

  /// Move uma linha de [oldIndex] para [newIndex] (resultado do ReorderableListView).
  void reorderLine(int oldIndex, int newIndex) {
    final updated = [...state.lines];
    final item = updated.removeAt(oldIndex);
    final insertAt = newIndex > oldIndex ? newIndex - 1 : newIndex;
    updated.insert(insertAt, item);
    state = state.copyWith(lines: updated, errorIndices: {});
  }

  void setSubmitting(bool value) {
    state = state.copyWith(submitting: value);
  }

  void setErrorIndices(Set<int> indices) {
    state = state.copyWith(errorIndices: indices);
  }

  void clearErrors() {
    state = state.copyWith(errorIndices: {});
  }

  void resetOrder(List<CodeLine> originalLines) {
    final shuffled = [...originalLines]..shuffle();
    state = SortingBoardState(
      lines: shuffled,
      submitting: false,
      errorIndices: {},
    );
  }
}
