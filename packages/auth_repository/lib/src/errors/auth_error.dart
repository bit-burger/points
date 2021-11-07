part 'auth_error_type.dart';

class AuthError implements Exception {
  final AuthErrorType type;

  AuthError(this.type);
}
