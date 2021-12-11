part of 'notification_cubit.dart';

@immutable
abstract class Notification {}

class MessageNotification extends Notification {
  final RelatedUser sender;
  final Message message;

  MessageNotification(this.sender, this.message);
}

class OtherNotification extends Notification {}
