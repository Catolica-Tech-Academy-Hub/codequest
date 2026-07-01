import 'package:codequest/features/trails/domain/entities/trail.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Trail Entity |', () {
    test('deve instanciar a entidade Trail corretamente com dados válidos', () {
      // 1. Arrange (Preparação): Criamos as variáveis de teste
      const id = 'trilha-01';
      const title = 'Introdução ao Dart';
      const description = 'Aprenda os conceitos fundamentais da linguagem.';
      const levelIds = ['level-1', 'level-2'];

      // 2. Act (Ação): Instanciamos a nossa entidade
      const trail = Trail(
        id: id,
        title: title,
        description: description,
        levelIds: levelIds,
      );

      // 3. Assert (Verificação): Validamos se a entidade guardou tudo certo
      expect(trail.id, equals('trilha-01'));
      expect(trail.title, equals('Introdução ao Dart'));
      expect(trail.description, isNotEmpty);
      expect(trail.levelIds, hasLength(2));
      expect(trail.levelIds.first, equals('level-1'));
    });
  });
}
