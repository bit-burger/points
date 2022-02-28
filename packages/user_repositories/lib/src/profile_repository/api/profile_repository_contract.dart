import '../../domain_shared/user.dart';

/// Edit points profile and listen to its changes
abstract class IProfileRepository {
  /// Listen to changes
  Stream<User> get profileStream;

  /// Current Profile which is the last profile
  /// to be have put in the [profileStream]
  User? get currentProfile;

  /// Update points profile
  Future<void> updateAccount({
    String? name,
    String? status,
    String? bio,
    int? color,
    int? icon,
  });

  /// Clean up
  void close();
}
