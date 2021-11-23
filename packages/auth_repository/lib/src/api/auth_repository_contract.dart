import '../domain/account_credentials.dart';

/// Repository for handling all auth related things
abstract class IAuthRepository {
  /// Try to log in from the persisted login
  /// throws [AuthAutoSignInFailedError] on failure
  Future<AccountCredentials> tryAutoSignIn();

  /// Login and persist the data
  Future<AccountCredentials> logIn(String email, String password);

  /// Sign up and persist the data
  Future<AccountCredentials> signUp(String email, String password);

  /// Logout and delete the persisted data
  Future<void> logOut();

  /// Delete the account and the persisted data
  Future<void> deleteAccount();
}
