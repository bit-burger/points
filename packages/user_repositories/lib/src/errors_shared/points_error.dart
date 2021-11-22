/// Superclass for all Point errors
abstract class PointsError implements Exception {
  final String message;

  PointsError(this.message);

  @override
  String toString() {
    return message;
  }
}
