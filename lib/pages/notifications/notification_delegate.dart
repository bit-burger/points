import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:points/state_management/notifications/notification_cubit.dart';
import 'package:points/widgets/neumorphic_box.dart';
import 'package:points/theme/points_colors.dart' as pointsColors;

class NotificationDelegate extends StatelessWidget {
  final Widget child;

  const NotificationDelegate({required this.child}) : super();

  Widget _buildMessageNotification(MessageNotification notification) {
    return NeumorphicBox(
      listPadding: true,
      color: pointsColors.colors[notification.sender?.color ?? 9],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(notification.sender?.name ?? "[UNRELATED USER]"),
          Text(notification.message.content),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationCubit, Notification?>(
      listener: (context, notification) {
        if (notification is MessageNotification) {
          InAppNotification.show(
            context: context,
            child: _buildMessageNotification(notification),
            onTap: () {
              final message = notification.message;
              Navigator.pushNamed(
                context,
                "/chat/${message.chatId}/${message.receiverId}",
              );
            },
          );
        }
      },
      child: child,
    );
  }
}
