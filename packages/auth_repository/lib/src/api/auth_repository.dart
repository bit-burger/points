import 'package:auth_repository/auth_repository.dart';
import 'package:supabase/supabase.dart';
import 'package:hive/hive.dart';

extension on GoTrueClient {
  void forceSignOut() {
    currentUser = null;
    currentSession = null;
  }
}

/// Supabase and hive implementation of the [IAuthRepository]
class AuthRepository extends IAuthRepository {
  final SupabaseClient _client;
  final Box<String> _sessionStore;

  AuthRepository({
    required SupabaseClient client,
    required Box<String> sessionStore,
  })  : _client = client,
        _sessionStore = sessionStore;

  @override
  Future<AccountCredentials> logIn(String email, String password) async {
    final response =
        await _client.auth.signIn(email: email, password: password);
    if (response.error == null) {
      await _saveSession(email, password);
      final user = response.user!;
      return AccountCredentials(userId: user.id, email: user.email!);
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
  Future<AccountCredentials> signUp(String email, String password) async {
    final response = await _client.auth.signUp(email, password);
    if (response.error != null) {
      switch (response.error!.message) {
        case "User already registered":
        case "Thanks for registering, " +
            "now check your email to complete the process.":
        case "A user with this email address has already been registered":
          throw AuthError(AuthErrorType.email);
        default:
          throw AuthError(AuthErrorType.connection);
      }
    }
    if (response.data == null) {
      throw AuthError(AuthErrorType.email);
    }
    await _saveSession(email, password);
    final user = response.user!;
    return AccountCredentials(userId: user.id, email: user.email!);
  }

  @override
  bool persistedLogInDataExists() {
    return _retrieveEmail() != null;
  }

  @override
  Future<AccountCredentials> tryAutoSignIn() async {
    final email = _retrieveEmail();
    if (email == null) {
      throw AuthAutoSignInFailedError();
    }
    final password = _retrievePassword();

    final response = await _client.auth.signIn(
      email: email,
      password: password,
    );

    switch (response.error?.message) {
      case null:
        final user = response.user!;
        return AccountCredentials(userId: user.id, email: user.email!);
      case "Session expired.":
      case "Missing currentSession.":
      case "Invalid Refresh Token":
        await _deleteSession();
        throw AuthAutoSignInFailedError();
      default:
        throw AuthError(AuthErrorType.connection);
    }
  }

  @override
  Future<void> logOut({bool keepPersistedData = false}) async {
    if (!keepPersistedData) {
      await _deleteSession();
    }
    final response = await _client.auth.signOut();
    if (response.error != null) {
      throw AuthError(AuthErrorType.connection);
    }
  }

  @override
  Future<void> deleteAccount() async {
    await _deleteSession();
    final response = await _client.rpc("delete_user").execute();
    _client.auth.forceSignOut();
    if (response.error != null) {
      throw AuthError(AuthErrorType.connection);
    }
  }

  Future<void> _deleteSession() async {
    await Future.wait([
      _sessionStore.delete("email"),
      _sessionStore.delete("password"),
    ]);
  }

  Future<void> _saveSession(String email, String password) async {
    await Future.wait([
      _sessionStore.put("email", email),
      _sessionStore.put("password", password),
    ]);
  }

  /// Can also be used to check,
  /// if any credentials that were saved exist
  String? _retrieveEmail() {
    return _sessionStore.get("email");
  }

  String _retrievePassword() {
    return _sessionStore.get("password")!;
  }
}
