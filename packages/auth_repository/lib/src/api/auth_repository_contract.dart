import '../domain/account_credentials.dart';

abstract class IAuthRepository {
  Future<AccountCredentials> tryAutoSignIn();

  Future<AccountCredentials> logIn(String email, String password);

  Future<AccountCredentials> signUp(String email, String password);

  Future<void> logOut();
}
