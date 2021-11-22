import '../../domain_shared/user.dart';

class ExactNameSearchParameter {}

abstract class IUserDiscoveryRepository {
  Future<User?> getUserByEmail({required String email});

  Future<List<User>> queryUsers({
    String? nameQuery,
    bool sortByPopularity = false,
    int pageIndex = 0,
    int pageLength = 10,
  });
}
