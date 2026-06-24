import 'package:flutter_test/flutter_test.dart';

import 'package:codequest/features/block_assembly/domain/entities/logic_block.dart';
import 'package:codequest/features/block_assembly/domain/value_objects/block_id.dart';
import 'package:codequest/features/block_assembly/domain/value_objects/block_label.dart';
import 'package:codequest/features/block_assembly/presentation/controllers/assembly_board_controller.dart';

void main() {
  group('AssemblyBoardNotifier', () {
    late AssemblyBoardNotifier notifier;

    setUp(() {
      notifier = AssemblyBoardNotifier();
    });

    group('inicialização', () {
      test('deve inicializar com estado vazio', () {
        expect(notifier.state.selectedSequence, isEmpty);
        expect(notifier.state.availableBlocks, isEmpty);
        expect(notifier.state.submitting, false);
        expect(notifier.state.validationErrors, isEmpty);
      });

      test('deve inicializar blocos disponíveis', () {
        // Arrange
        final blocks = [
          LogicBlock(
            id: const BlockId('b1'),
            label: const BlockLabel('Bloco 1'),
            expectedPosition: 0,
          ),
          LogicBlock(
            id: const BlockId('b2'),
            label: const BlockLabel('Bloco 2'),
            expectedPosition: 1,
          ),
        ];

        // Act
        notifier.initializeBlocks(blocks);

        // Assert
        expect(notifier.state.availableBlocks, equals(blocks));
        expect(notifier.state.selectedSequence, isEmpty);
        expect(notifier.state.isSequenceFull, false);
      });
    });

    group('adicionar blocos', () {
      setUp(() {
        final blocks = [
          LogicBlock(
            id: const BlockId('b1'),
            label: const BlockLabel('Bloco 1'),
            expectedPosition: 0,
          ),
          LogicBlock(
            id: const BlockId('b2'),
            label: const BlockLabel('Bloco 2'),
            expectedPosition: 1,
          ),
        ];
        notifier.initializeBlocks(blocks);
      });

      test('deve adicionar bloco na primeira posição', () {
        // Act
        final block = notifier.state.availableBlocks[0];
        notifier.addBlockAtPosition(0, block);

        // Assert
        expect(notifier.state.selectedSequence.length, 1);
        expect(notifier.state.selectedSequence[0], block);
        expect(notifier.state.isSequenceFull, false);
      });

      test('deve adicionar bloco em posição intermediária', () {
        // Arrange
        final block1 = notifier.state.availableBlocks[0];
        final block2 = notifier.state.availableBlocks[1];

        // Act
        notifier.addBlockAtPosition(0, block1);
        notifier.addBlockAtPosition(1, block2);

        // Assert
        expect(notifier.state.selectedSequence.length, 2);
        expect(notifier.state.isSequenceFull, true);
      });

      test('deve manter ordem de inserção', () {
        // Arrange
        final block1 = notifier.state.availableBlocks[0];
        final block2 = notifier.state.availableBlocks[1];

        // Act
        notifier.addBlockAtPosition(0, block1);
        notifier.addBlockAtPosition(1, block2);

        // Assert
        expect(notifier.state.selectedSequence[0].id.value, 'b1');
        expect(notifier.state.selectedSequence[1].id.value, 'b2');
      });

      test('deve limpar erros ao adicionar bloco', () {
        // Arrange
        final block = notifier.state.availableBlocks[0];
        notifier.setValidationErrors({0, 1});

        // Act
        notifier.addBlockAtPosition(0, block);

        // Assert
        expect(notifier.state.validationErrors, isEmpty);
      });
    });

    group('remover blocos', () {
      setUp(() {
        final blocks = [
          LogicBlock(
            id: const BlockId('b1'),
            label: const BlockLabel('Bloco 1'),
            expectedPosition: 0,
          ),
          LogicBlock(
            id: const BlockId('b2'),
            label: const BlockLabel('Bloco 2'),
            expectedPosition: 1,
          ),
        ];
        notifier.initializeBlocks(blocks);

        // Adicionar dois blocos
        notifier.addBlockAtPosition(0, blocks[0]);
        notifier.addBlockAtPosition(1, blocks[1]);
      });

      test('deve remover bloco de posição específica', () {
        // Act
        notifier.removeBlockAtPosition(0);

        // Assert
        expect(notifier.state.selectedSequence.length, 1);
        expect(notifier.state.selectedSequence[0].id.value, 'b2');
      });

      test('deve não remover se posição inválida', () {
        // Act
        notifier.removeBlockAtPosition(99);

        // Assert
        expect(notifier.state.selectedSequence.length, 2);
      });

      test('deve limpar erros ao remover', () {
        // Arrange
        notifier.setValidationErrors({0});

        // Act
        notifier.removeBlockAtPosition(0);

        // Assert
        expect(notifier.state.validationErrors, isEmpty);
      });
    });

    group('mover blocos', () {
      setUp(() {
        final blocks = [
          LogicBlock(
            id: const BlockId('b1'),
            label: const BlockLabel('Bloco 1'),
            expectedPosition: 0,
          ),
          LogicBlock(
            id: const BlockId('b2'),
            label: const BlockLabel('Bloco 2'),
            expectedPosition: 1,
          ),
        ];
        notifier.initializeBlocks(blocks);

        notifier.addBlockAtPosition(0, blocks[0]);
        notifier.addBlockAtPosition(1, blocks[1]);
      });

      test('deve mover bloco de uma posição para outra', () {
        // Act
        notifier.moveBlock(0, 1);

        // Assert
        expect(notifier.state.selectedSequence[0].id.value, 'b2');
        expect(notifier.state.selectedSequence[1].id.value, 'b1');
      });

      test('deve não mover se posição inválida', () {
        // Arrange
        final originalSeq = List.of(notifier.state.selectedSequence);

        // Act
        notifier.moveBlock(99, 0);

        // Assert
        expect(notifier.state.selectedSequence, equals(originalSeq));
      });
    });

    group('limpar sequência', () {
      setUp(() {
        final blocks = [
          LogicBlock(
            id: const BlockId('b1'),
            label: const BlockLabel('Bloco 1'),
            expectedPosition: 0,
          ),
        ];
        notifier.initializeBlocks(blocks);
        notifier.addBlockAtPosition(0, blocks[0]);
        notifier.setValidationErrors({0});
      });

      test('deve limpar sequência e erros', () {
        // Act
        notifier.clearSequence();

        // Assert
        expect(notifier.state.selectedSequence, isEmpty);
        expect(notifier.state.validationErrors, isEmpty);
      });
    });

    group('estado de submissão', () {
      test('deve alterar flag submitting', () {
        // Act
        notifier.setSubmitting(true);

        // Assert
        expect(notifier.state.submitting, true);

        // Act
        notifier.setSubmitting(false);

        // Assert
        expect(notifier.state.submitting, false);
      });
    });

    group('erros de validação', () {
      test('deve marcar erros em posições específicas', () {
        // Act
        notifier.setValidationErrors({0, 2, 4});

        // Assert
        expect(notifier.state.validationErrors, equals({0, 2, 4}));
        expect(notifier.state.firstErrorIndex, 0);
      });

      test('deve limpar erros', () {
        // Arrange
        notifier.setValidationErrors({0, 1});

        // Act
        notifier.clearValidationErrors();

        // Assert
        expect(notifier.state.validationErrors, isEmpty);
        expect(notifier.state.firstErrorIndex, -1);
      });
    });

    group('verificações de estado', () {
      setUp(() {
        final blocks = [
          LogicBlock(
            id: const BlockId('b1'),
            label: const BlockLabel('Bloco 1'),
            expectedPosition: 0,
          ),
          LogicBlock(
            id: const BlockId('b2'),
            label: const BlockLabel('Bloco 2'),
            expectedPosition: 1,
          ),
        ];
        notifier.initializeBlocks(blocks);
      });

      test('deve indicar sequência incompleta', () {
        // Arrange
        notifier.addBlockAtPosition(0, notifier.state.availableBlocks[0]);

        // Assert
        expect(notifier.state.isSequenceFull, false);
      });

      test('deve indicar sequência completa', () {
        // Arrange
        notifier.addBlockAtPosition(0, notifier.state.availableBlocks[0]);
        notifier.addBlockAtPosition(1, notifier.state.availableBlocks[1]);

        // Assert
        expect(notifier.state.isSequenceFull, true);
      });
    });
  });
}
