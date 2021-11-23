part 'auth_error_type.dart';

/// All auth errors with exception of the [AuthAutoSignF
class AuthError implements Exception {
  final AuthErrorType type;

  AuthError(this.type);
}
