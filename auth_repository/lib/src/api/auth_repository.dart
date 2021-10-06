import '../errors/auth_auto_sign_in_not_found_error.dart';

import '../errors/auth_error.dart';

import 'api_contract.dart';

import 'package:gotrue/gotrue.dart';
import 'package:hive/hive.dart';

class AuthRepository extends IAuthRepository {
  final GoTrueClient _authClient;
  final Box<String> _sessionStore;

  AuthRepository({
    required GoTrueClient authClient,
    required Box<String> sessionStore,
  })  : _authClient = authClient,
        _sessionStore = sessionStore;

  @override
  Future<String> logIn(String email, String password) async {
    final response = await _authClient.signIn(email: email, password: password);
    if (response.error == null) {
      return response.user!.id;
    }
    switch (response.error!.message) {
      case "Invalid login credentials":
        throw AuthError(AuthErrorType.email);
      case "Invalid email or password":
        throw AuthError(AuthErrorType.password);
      default:
        throw AuthError(AuthErrorType.connection);
    }
  }

  @override
  Future<String> signUp(String email, String password) async {
    final response = await _authClient.signUp(email, password);
    if (response.error == null) {
      return response.user!.id;
    }
    switch (response.error!.message) {
      case "A user with this email address has already been registered":
        throw AuthError(AuthErrorType.email);
      case "Invalid email or password":
        throw AuthError(AuthErrorType.password);
      default:
        throw AuthError(AuthErrorType.connection);
    }
  }

  @override
  Future<void> signOut() async {
    final response = await _authClient.signOut();
    if (response.error != null) {
      throw AuthError(AuthErrorType.connection);
    }
  }

  @override
  Future<String> tryAutoSignIn() async {
    final jsonStr = _sessionStore.get("sessionTokenJsonStr");
    if (jsonStr == null) {
      throw AuthAutoSignInNotFoundError();
    }

    final response = await _authClient.recoverSession(jsonStr);
    if (response.error != null) {
      throw AuthError(AuthErrorType.connection);
    }
    return response.user!.id;
  }
}
