import 'package:supabase/supabase.dart' hide User;
import 'package:user_repositories/profile_repository.dart';

import '../user_discovery_function_names.dart' as functions;

import 'user_discovery_repository_contract.dart';

/// Supabase implementation of [IUserDiscoveryRepository]
class UserDiscoveryRepository extends IUserDiscoveryRepository {
  final SupabaseClient _client;

  UserDiscoveryRepository({
    required SupabaseClient client,
  }) : _client = client;

  @override
  Future<User?> getUserByEmail({
    required String email,
  }) async {
    final response = await _client
        .rpc(functions.profileFromEmail, params: {"_email": email}).execute();

    if (response.error != null) {
      throw PointsConnectionError();
    }

    assert(response.data.length < 2);

    if (response.data.length == 0) {
      return null;
    }

    return User.fromJson(response.data[0]);
  }

  @override
  Future<User> getUserById({required String id}) async {
    final response =
        await _client.from("profiles").select().eq("id", id).single().execute();

    if (response.error != null) {
      throw PointsConnectionError();
    }

    return User.fromJson(response.data);
  }

  /*
    imprecise name
    imprecise name  + popularity
    no name
    no name         + popularity
  */
  @override
  Future<List<User>> queryUsers({
    String? nameQuery,
    bool sortByPopularity = false,
    int pageIndex = 0,
    int pageLength = 20,
  }) async {
    assert(pageIndex >= 0);
    assert(pageLength > 0);

    late final PostgrestTransformBuilder query;

    if (nameQuery == null) {
      // Queries without name
      query = _client.rpc(
        functions.queryProfiles(
          sortByPopularity: sortByPopularity,
        ),
      );
    } else {
      // Queries with name
      query = _client.rpc(
        functions.queryProfiles(
          searchWithName: true,
          sortByPopularity: sortByPopularity,
        ),
        params: {"_name": nameQuery},
      );
    }

    query.page(pageIndex, pageLength: pageLength);

    final response = await query.execute();

    if (response.error != null) {
      throw PointsConnectionError();
    }

    return _usersFromRows(response.data);
  }

  List<User> _usersFromRows(dynamic list) {
    final rawUsers = (list as List);
    return rawUsers
        .map<User>((rawUser) => User.fromJson(rawUser))
        .toList(growable: false);
  }
}

extension on PostgrestTransformBuilder {
  PostgrestTransformBuilder page(
    int pageIndex, {
    required int pageLength,
  }) {
    final startingIndex = pageIndex * pageLength;
    final endIndex = startingIndex + (pageLength - 1);
    return range(startingIndex, endIndex);
  }
}
