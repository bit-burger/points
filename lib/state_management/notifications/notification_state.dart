part of 'notification_cubit.dart';

@immutable
class Notification {
  final int? id;
  final bool important;

  final Color color;
  final IconData? icon;
  final String? title;
  final String message;

  Notification({
    this.id,
    this.important = true,
    required this.color,
    this.icon,
    this.title,
    required this.message,
  });
}

class MessageNotification extends Notification {
  final String openChatId;
  final String openChatUserId;

  MessageNotification(
    this.openChatId,
    this.openChatUserId, {
    required Color color,
    IconData? icon,
    String? title,
    required String message,
  }) : super(
          color: color,
          icon: icon,
          title: title,
          message: message,
        );
}
