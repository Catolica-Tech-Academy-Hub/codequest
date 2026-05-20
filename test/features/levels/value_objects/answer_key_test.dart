import 'package:codequest/features/levels/domain/errors/level_failure.dart';
import 'package:codequest/features/levels/domain/value_objects/answer_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnswerKey', () {
    test('aceita letra minúscula a-z', () {
      for (final c in <String>['a', 'b', 'm', 'z']) {
        expect(AnswerKey(c).value, c);
      }
    });

    test('rejeita maiúscula', () {
      expect(() => AnswerKey('A'), throwsA(isA<InvalidAnswerKeyFailure>()));
    });

    test('rejeita dígito', () {
      expect(() => AnswerKey('1'), throwsA(isA<InvalidAnswerKeyFailure>()));
    });

    test('rejeita múltiplos caracteres', () {
      expect(() => AnswerKey('ab'), throwsA(isA<InvalidAnswerKeyFailure>()));
    });

    test('rejeita vazio', () {
      expect(() => AnswerKey(''), throwsA(isA<InvalidAnswerKeyFailure>()));
    });

    test('igualdade por valor', () {
      expect(AnswerKey('a'), equals(AnswerKey('a')));
      expect(AnswerKey('a'), isNot(equals(AnswerKey('b'))));
    });

    test('funciona dentro de Set', () {
      final set = <AnswerKey>{AnswerKey('a'), AnswerKey('a'), AnswerKey('b')};
      expect(set.length, 2);
    });
  });
}
