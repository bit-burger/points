part of 'profile_repository.dart';

abstract class IPointsProfileRepository {
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
