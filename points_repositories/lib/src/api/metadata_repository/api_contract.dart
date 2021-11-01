part of 'metadata_repository.dart';

abstract class IPointsMetadataRepository {
  Future<String> getVersion();
}
