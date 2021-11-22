/// Read metadata from server (probably only the version)
abstract class IPointsMetadataRepository {
  Future<String> getVersion();
}
