/// Given back if logged in
class AccountCredentials {
  final String userId;
  final String email;

  AccountCredentials({
    required this.userId,
    required this.email,
  });

  @override
  String toString() {
    return '{user-ID: $userId, email: $email}';
  }
}
