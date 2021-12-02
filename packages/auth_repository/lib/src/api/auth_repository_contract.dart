import '../domain/account_credentials.dart';

/// Repository for handling all auth related things
abstract class IAuthRepository {
  /// Checks if a session for the user was saved and
  /// the auto sign in can be attempted
  bool persistedLogInDataExists();

  /// Try to log in from the persisted login
  /// throws [AuthAutoSignInFailedError] on failure
  Future<AccountCredentials> tryAutoSignIn();

  /// Login and persist the data
  Future<AccountCredentials> logIn(String email, String password);

  /// Sign up and persist the data
  Future<AccountCredentials> signUp(String email, String password);

  /// Logout and delete the persisted data
  Future<void> logOut({bool keepPersistedData = false});

  /// Delete the account and the persisted data
  Future<void> deleteAccount();
}
