abstract class IAuthRepository {
  Future<String> tryAutoSignIn();

  Future<String> logIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future logOut();
}
