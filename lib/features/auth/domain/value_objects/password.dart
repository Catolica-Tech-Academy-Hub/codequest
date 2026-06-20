import 'package:codequest/features/auth/domain/errors/auth_failure.dart';

class Password {
  Password(String rawValue) : value = rawValue {
    if (value.length < 8 || !_hasLetterAndNumber(value)) {
      throw AuthFailure.invalidPasswordPolicy();
    }
  }

  static bool _hasLetterAndNumber(String input) {
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(input);
    final hasNumber = RegExp(r'\d').hasMatch(input);
    return hasLetter && hasNumber;
  }

  final String value;
}
