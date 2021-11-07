import '../../domain_shared/root_user.dart';

abstract class IProfileRepository {
  Stream<RootUser?> get profileStream;

  Future<void> createAccount(String name);

  Future<void> updateAccount({
    String? name,
    String? status,
    String? bio,
    int? color,
    int? icon,
  });

  Future<void> deleteAccount();

  void close();
}
