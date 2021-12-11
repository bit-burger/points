import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart' hide Notification;
import 'package:in_app_notification/in_app_notification.dart';
import 'package:points/state_management/notifications/notification_cubit.dart';
import 'package:points/widgets/neumorphic_box.dart';
import 'package:provider/single_child_widget.dart';

import 'package:points/theme/points_colors.dart' as pointsColors;
import 'package:points/theme/points_icons.dart' as pointsIcons;

class NotificationDelegate extends SingleChildStatelessWidget {
  final void Function(String chatId, String userId) chatOpenCallback;

  const NotificationDelegate({
    Widget? child,
    required this.chatOpenCallback,
  }) : super(child: child);

  Widget _buildMessageNotification(
    BuildContext context,
    MessageNotification notification,
  ) {
    return NeumorphicBox(
      listPadding: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(pointsIcons.pointsIcons[notification.sender.icon]),
            SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.sender.name,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Text(
                    notification.message.content,
                    maxLines: 10,
                    overflow: TextOverflow.fade,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      style: NeumorphicStyle(
        color: pointsColors.colors[notification.sender.color],
        depth: 8,
      ),
    );
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return BlocListener<NotificationCubit, Notification?>(
      child: child,
      listener: (context, notification) {
        if (notification is MessageNotification) {
          InAppNotification.show(
            context: context,
            duration: Duration(milliseconds: 2500),
            child: _buildMessageNotification(context, notification),
            onTap: () {
              final message = notification.message;
              chatOpenCallback(message.chatId, message.receiverId);
            },
          );
        }
      },
    );
  }
}
