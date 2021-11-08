class UserNotFoundEmailError implements Exception {
  final String email;

  UserNotFoundEmailError(this.email);

  @override
  String toString() {
    return "Could not find user with email '$email'";
  }
}
