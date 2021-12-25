import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart' hide Notification;
import 'package:in_app_notification/in_app_notification.dart';
import 'package:points/state_management/notifications/notification_cubit.dart';
import 'package:points/widgets/neumorphic_box.dart';
import 'package:provider/single_child_widget.dart';

class NotificationDelegate extends SingleChildStatelessWidget {
  final void Function(String chatId, String userId) chatOpenCallback;

  const NotificationDelegate({
    Widget? child,
    required this.chatOpenCallback,
  }) : super(child: child);

  Widget _buildNotification(
    BuildContext context,
    Notification notification,
  ) {
    return NeumorphicBox(
      listPadding: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (notification.icon != null)
              Icon(
                notification.icon,
              ),
            SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notification.title != null)
                    Text(
                      notification.title!,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  Text(
                    notification.message,
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
        color: notification.color,
        depth: 8,
      ),
    );
  }

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
            child: _buildNotification(context, notification),
            onTap: notification is! MessageNotification
                ? null
                : () {
                    chatOpenCallback(
                      notification.openChatId,
                      notification.openChatUserId,
                    );
                  },
          );
        }
      },
    );
  }
}
