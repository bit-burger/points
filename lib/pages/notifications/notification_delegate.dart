import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart' hide Notification;
import 'package:in_app_notification/in_app_notification.dart';
import 'package:points/state_management/notifications/notification_cubit.dart';
import 'package:provider/single_child_widget.dart';

import 'notification_widget.dart';

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
