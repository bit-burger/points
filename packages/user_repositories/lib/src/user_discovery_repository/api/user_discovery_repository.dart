import 'package:supabase/supabase.dart' hide User;
import 'package:user_repositories/profile_repository.dart';
import '../../domain_shared/user.dart';

import '../user_discovery_function_names.dart' as functions;

import 'user_discovery_repository_contract.dart';

class UserDiscoveryRepository extends IUserDiscoveryRepository {
  final SupabaseClient _client;

  UserDiscoveryRepository({
    required SupabaseClient client,
  }) : _client = client;

  @override
  Future<User> getUserByEmail({
    required String email,
  }) async {
    final userIdResponse = await _client
        .rpc(functions.getUserIdFromEmail, params: {"_email": email}).execute();
    if (userIdResponse.error != null) {
      throw PointsConnectionError();
    }
    final profilesResponse = await _client
        .from("profiles")
        .select()
        .eq("id", userIdResponse.data)
        .single()
        .execute();

    if (profilesResponse.error != null) {
      throw PointsConnectionError();
    }
    return User.fromJson(profilesResponse.data);
  }

  /*
    exact name
    exact name     + popularity
    (imprecise name)
    imprecise name + popularity
    no name
    no name        + popularity
  */

  // TODO: imprecise name + popularity: order by levenschtein(name) / 10, points
  // TODO: Profiles ausschließen die blockiert sind (per join mit relations)
  @override
  Future<List<User>> queryUsers({
    String? nameQuery,
    bool nameIsExact = false,
    bool sortByPopularity = false,
    int page = 0,
    int pageLength = 10,
  }) async {
    assert(page >= 0);
    assert(pageLength > 0);
    assert(!nameIsExact || nameQuery == null);

    if (nameIsExact) {
      return _queryUsersWithPreciseOrWithoutName(
          nameQuery, sortByPopularity, page, pageLength);
    }

    if (nameQuery != null) {
      return _queryUsersImpreciseName(
          nameQuery, sortByPopularity, page, pageLength);
    }

    return _queryUsersWithPreciseOrWithoutName(
        nameQuery, sortByPopularity, page, pageLength);
  }

  Future<List<User>> _queryUsersWithPreciseOrWithoutName(
    String? nameQuery,
    bool sortByPopularity,
    int page,
    int pageLength,
  ) async {
    var query = _client.from("profiles").select();

    if (nameQuery != null) {
      query.eq("name", nameQuery);
    }

    if (sortByPopularity) {
      query.order("points");
    }

    final startingIndex = (page - 1) * pageLength;
    final endIndex = startingIndex + pageLength - 1;
    query.range(startingIndex, endIndex);

    final response = await query.execute();
    if (response.error != null) {
      throw PointsConnectionError();
    }
    return _usersFromRows(response.data);
  }

  Future<List<User>> _queryUsersImpreciseName(
    String nameQuery,
    bool sortByPopularity,
    int page,
    int pageLength,
  ) async {
    throw UnimplementedError();
  }

  List<User> _usersFromRows(dynamic list) {
    final rawUsers = (list as List);
    return rawUsers
        .map<User>((rawUser) => User.fromJson(rawUser))
        .toList(growable: false);
  }
}
