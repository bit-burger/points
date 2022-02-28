import '../../domain_shared/user.dart';

/// Repository for finding, querying and fetching users in points
abstract class IUserDiscoveryRepository {
  /// Get a [User] by their email,
  /// will return null if not found
  Future<User?> getUserByEmail({required String email});

  /// Get a [User] by their id
  Future<User> getUserById({required String id});

  /// Query and page users by different criteria, criteria include:
  /// * name
  /// * sorting by points
  Future<List<User>> queryUsers({
    String? nameQuery,
    bool sortByPopularity = false,
    int pageIndex = 0,
    int pageLength = 10,
  });
}
