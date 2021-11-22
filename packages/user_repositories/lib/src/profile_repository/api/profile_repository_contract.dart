import '../../domain_shared/user.dart';

abstract class IProfileRepository {
  Stream<User> get profileStream;

  User? get currentProfile;

  Future<void> updateAccount({
    String? name,
    String? status,
    String? bio,
    int? color,
    int? icon,
  });

  void close();
}
