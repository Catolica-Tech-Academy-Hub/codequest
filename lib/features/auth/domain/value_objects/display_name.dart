import 'package:codequest/features/auth/domain/errors/auth_failure.dart';

class DisplayName {
  DisplayName(String rawValue) : value = rawValue.trim() {
    if (value.length < 2 || value.length > 50) {
      throw AuthFailure.invalidDisplayName();
    }
  }

  final String value;
}
