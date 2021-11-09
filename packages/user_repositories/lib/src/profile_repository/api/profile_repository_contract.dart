import '../../domain_shared/root_user.dart';

abstract class IProfileRepository {
  // TODO: RootUser does not need to be null
  Stream<RootUser?> get profileStream;

  Future<void> updateAccount({
    String? name,
    String? status,
    String? bio,
    int? color,
    int? icon,
  });

  void close();
}
