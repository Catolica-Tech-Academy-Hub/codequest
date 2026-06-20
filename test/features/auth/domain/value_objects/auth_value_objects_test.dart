import 'package:codequest/features/auth/domain/errors/auth_failure.dart';
import 'package:codequest/features/auth/domain/value_objects/display_name.dart';
import 'package:codequest/features/auth/domain/value_objects/email_address.dart';
import 'package:codequest/features/auth/domain/value_objects/password.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmailAddress', () {
    test('normaliza e-mail valido', () {
      final email = EmailAddress('  User@Test.Com  ');

      expect(email.value, 'user@test.com');
    });

    test('lanca AuthFailure para formato invalido', () {
      expect(
        () => EmailAddress('email-invalido'),
        throwsA(isA<AuthFailure>()),
      );
    });
  });

  group('Password', () {
    test('aceita senha com 8+ caracteres, letra e numero', () {
      final password = Password('Abcdef12');

      expect(password.value, 'Abcdef12');
    });

    test('lanca AuthFailure quando senha nao atende politica', () {
      expect(
        () => Password('12345678'),
        throwsA(isA<AuthFailure>()),
      );
    });
  });

  group('DisplayName', () {
    test('aceita nome entre 2 e 50 caracteres', () {
      final name = DisplayName('Ana');

      expect(name.value, 'Ana');
    });

    test('lanca AuthFailure para nome muito curto', () {
      expect(
        () => DisplayName('A'),
        throwsA(isA<AuthFailure>()),
      );
    });
  });
}
