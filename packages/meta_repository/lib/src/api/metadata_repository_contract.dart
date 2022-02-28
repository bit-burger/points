/// Read metadata from server (probably only the version)
abstract class IMetadataRepository {
  Future<String> getVersion();
  Future<bool> hasConnection();
}
