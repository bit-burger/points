import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart' hide Notification;
import 'package:in_app_notification/in_app_notification.dart';
import 'package:points/state_management/notifications/notification_cubit.dart';
import 'package:provider/single_child_widget.dart';
import '../home/home_navigator.dart';
import '../chat/chat_page.dart';
import '../notifications/notifications_page.dart';

import '../../widgets/notification_widget.dart';

/// Listens to the [NotificationCubit]
/// and uses the [InAppNotification]
/// inserted in [Points] (the root widget),
/// to show in app notifications in the whole app.
///
/// via the [chatOpenCallback] and the [notificationsOpenCallback],
/// the [HomeNavigator] opens the [ChatPage] or the [NotificationsPage].
class NotificationDelegate extends SingleChildStatelessWidget {
  final void Function(String chatId, String userId) chatOpenCallback;
  final void Function() notificationsOpenCallback;

  const NotificationDelegate({
    Widget? child,
    required this.chatOpenCallback,
    required this.notificationsOpenCallback,
  }) : super(child: child);

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return BlocListener<NotificationCubit, Notification?>(
      child: child,
      listener: (context, notification) {
        if (notification != null) {
          InAppNotification.show(
            context: context,
            duration: Duration(
              milliseconds: notification.important ? 3000 : 1000,
            ),
            child: NotificationWidget(
              icon: notification.icon,
              title: notification.title,
              message: notification.message,
              color: notification.color,
            ),
            onTap: () {
              // Mark the notification as read if clicked on
              context.read<NotificationCubit>().markAsRead();

              if (notification is MessageNotification) {
                chatOpenCallback(
                  notification.openChatId,
                  notification.openChatUserId,
                );
              } else {
                notificationsOpenCallback();
              }
            },
          );
        }
      },
    );
  }
}
