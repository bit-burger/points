import '../../domain_shared/user.dart';

/// Repository for finding users in points
abstract class IUserDiscoveryRepository {
  /// Get a [User] by their email,
  /// will return null if not found
  Future<User?> getUserByEmail({required String email});

  /// Query users by different criteria, criteria include:
  /// * name
  /// * sorting by points
  ///
  /// Paging is also supported
  Future<List<User>> queryUsers({
    String? nameQuery,
    bool sortByPopularity = false,
    int pageIndex = 0,
    int pageLength = 10,
  });
}
