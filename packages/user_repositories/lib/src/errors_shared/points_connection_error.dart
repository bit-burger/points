import 'points_error.dart';

/// Is thrown on a connection error
class PointsConnectionError extends PointsError {
  PointsConnectionError() : super("The connection failed");
}
