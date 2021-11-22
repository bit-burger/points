import '../../errors_shared/points_error.dart';

/// Thrown when a relation is not allowed
class PointsIllegalRelationError extends PointsError {
  PointsIllegalRelationError() : super("The relation is not supported");
}
