import 'package:flutter_test/flutter_test.dart';

import 'package:codequest/features/block_assembly/domain/entities/logic_block.dart';
import 'package:codequest/features/block_assembly/domain/value_objects/block_id.dart';
import 'package:codequest/features/block_assembly/domain/value_objects/block_label.dart';

void main() {
  group('Domain Entities - LogicBlock', () {
    test('deve criar um LogicBlock com valores corretos', () {
      // Arrange & Act
      final block = LogicBlock(
        id: const BlockId('block-001'),
        label: const BlockLabel('void main()'),
        expectedPosition: 0,
      );

      // Assert
      expect(block.id.value, 'block-001');
      expect(block.label.value, 'void main()');
      expect(block.expectedPosition, 0);
    });

    test('LogicBlocks iguais devem ser equivalentes', () {
      // Arrange
      final block1 = LogicBlock(
        id: const BlockId('b1'),
        label: const BlockLabel('Block'),
        expectedPosition: 0,
      );

      final block2 = LogicBlock(
        id: const BlockId('b1'),
        label: const BlockLabel('Block'),
        expectedPosition: 0,
      );

      // Assert
      expect(block1, equals(block2));
    });

    test('LogicBlocks diferentes não devem ser equivalentes', () {
      // Arrange
      final block1 = LogicBlock(
        id: const BlockId('b1'),
        label: const BlockLabel('Block 1'),
        expectedPosition: 0,
      );

      final block2 = LogicBlock(
        id: const BlockId('b2'),
        label: const BlockLabel('Block 2'),
        expectedPosition: 1,
      );

      // Assert
      expect(block1, isNot(equals(block2)));
    });
  });

  group('Domain Value Objects', () {
    test('BlockId deve armazenar valor corretamente', () {
      // Arrange & Act
      const blockId = BlockId('test-id');

      // Assert
      expect(blockId.value, 'test-id');
    });

    test('BlockIds iguais devem ser equivalentes', () {
      // Arrange
      const id1 = BlockId('same-id');
      const id2 = BlockId('same-id');

      // Assert
      expect(id1, equals(id2));
    });

    test('BlockLabel deve armazenar valor corretamente', () {
      // Arrange & Act
      const label = BlockLabel('print("Hello")');

      // Assert
      expect(label.value, 'print("Hello")');
    });

    test('BlockLabels iguais devem ser equivalentes', () {
      // Arrange
      const label1 = BlockLabel('same-label');
      const label2 = BlockLabel('same-label');

      // Assert
      expect(label1, equals(label2));
    });
  });
}
