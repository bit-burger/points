import 'points_error.dart';

/// Error thrown when the connection failed
class PointsConnectionError extends PointsError {
  PointsConnectionError() : super("The connection failed");
}
