/// Is thrown on a connection error
class MessageConnectionError implements Exception {
  @override
  String toString() {
    return "Message connection failed";
  }
}
