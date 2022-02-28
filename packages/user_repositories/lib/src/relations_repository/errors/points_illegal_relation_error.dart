import '../../errors_shared/points_error.dart';

/// Thrown when a relation is not allowed,
/// for example when you try to send a friend request
/// to someone that has blocked you
class PointsIllegalRelationError extends PointsError {
  PointsIllegalRelationError() : super("The relation is not supported");
}
