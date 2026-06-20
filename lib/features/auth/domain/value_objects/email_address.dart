import 'package:codequest/features/auth/domain/errors/auth_failure.dart';

class EmailAddress {
  EmailAddress(String rawValue) : value = rawValue.trim().toLowerCase() {
    if (!_emailRegex.hasMatch(value)) {
      throw AuthFailure.invalidEmail();
    }
  }

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  final String value;
}
