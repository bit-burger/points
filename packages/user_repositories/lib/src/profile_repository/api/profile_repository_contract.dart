import '../../domain_shared/user.dart';

abstract class IProfileRepository {
  // TODO: RootUser does not need to be null
  Stream<User?> get profileStream;

  Future<void> updateAccount({
    String? name,
    String? status,
    String? bio,
    int? color,
    int? icon,
  });

  void close();
}
