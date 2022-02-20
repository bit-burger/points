import 'package:supabase/supabase.dart';

import 'metadata_repository_contract.dart';

/// Supabase implementation of [IMetadataRepository]
class MetadataRepository extends IMetadataRepository {
  final SupabaseClient _client;

  MetadataRepository({
    required SupabaseClient client,
  }) : _client = client;

  /// not currently implemented, will probably not be implemented
  @deprecated
  @override
  Future<String> getVersion() {
    // TODO: implement getVersion
    throw UnimplementedError();
  }

  @override
  Future<bool> hasConnection() async {
    final response = await _client.rpc("check_connection").execute();
    if (response.error != null) {
      return false;
    }
    return response.data;
  }
}
