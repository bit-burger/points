import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide NeumorphicAppBar;
import 'package:ionicons/ionicons.dart';
import 'package:points/helpers/notification_type_icon_data.dart';
import 'package:points/state_management/notifications/notification_paging_cubit.dart';
import 'package:points/theme/points_colors.dart' as pointsColors;
import 'package:points/widgets/loader.dart';
import 'package:points/widgets/neumorphic_app_bar_fix.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'notification_widget.dart';

class NotificationPage extends StatefulWidget {
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  Widget _buildListView(NotificationPagingData data) {
    return ScrollablePositionedList.builder(
      padding: MediaQuery.of(context).viewPadding + EdgeInsets.only(top: 72),
      itemPositionsListener: itemPositionsListener,
      itemCount: data.notifications.length + (data.moreToLoad ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (index < data.notifications.length) {
          final notification = data.notifications[index];
          final unknownUser = notification.unknownUserId == null
              ? null
              : data.mentionedUsers
                  .firstWhere((user) => user.id == notification.unknownUserId);
          final knownUser = data.mentionedUsers
              .firstWhere((user) => user.id == notification.selfId);

          final firstUser = notification.firstActorId == unknownUser?.id
              ? unknownUser
              : knownUser;
          final secondUser = notification.secondActorId == unknownUser?.id
              ? unknownUser
              : knownUser;

          final mainUser = (firstUser ?? secondUser!);
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: NotificationWidget(
              lessSpacing: true,
              icon: iconDataFromNotificationType(notification.type),
              message: notification.getNotificationMessage(unknownUser?.name),
              color: pointsColors.colors[
                  mainUser.id == notification.selfId ? 9 : mainUser.color],
              read: notification.hasRead,
            ),
          );
        }
        return _buildLoader();
      },
    );
  }

  Widget _buildLoader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Loader(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicScaffold(
      appBar: NeumorphicAppBar(
        leading: NeumorphicBackButton(
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.circle(),
          ),
        ),
        title: Neumorphic(
          child: SizedBox(
            height: 56,
            child: Center(
              child: Text(
                "10 Unread",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.stadium(),
          ),
        ),
        trailing: NeumorphicButton(
          tooltip: "Mark all read",
          child: Icon(Ionicons.checkmark_done_outline),
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.circle(),
          ),
          onPressed: () {
            context.read<NotificationPagingCubit>().markAllRead();
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: BlocBuilder<NotificationPagingCubit, NotificationPagingState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 400),
            child: state is NotificationPagingData
                ? _buildListView(state)
                : _buildLoader(),
          );
        },
      ),
    );
  }

  void _scrollChanged() {
    final pagingCubit = context.read<NotificationPagingCubit>();
    if (pagingCubit.state is NotificationPagingData) {
      final pagingData = (pagingCubit.state as NotificationPagingData);
      final visible = itemPositionsListener.itemPositions.value;

      if (visible.last.index == pagingData.notifications.length) {
        pagingCubit.loadMore();
      }
    }
  }

  @override
  void initState() {
    itemPositionsListener.itemPositions.addListener(_scrollChanged);
    super.initState();
  }
}
