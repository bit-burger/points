import 'points_error.dart';

class PointsIllegalRelationError extends PointsError {
  PointsIllegalRelationError() : super("The relation is not supported");
}
