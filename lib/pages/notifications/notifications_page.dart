import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide NeumorphicAppBar;
import 'package:ionicons/ionicons.dart';
import 'package:points/helpers/notification_type_icon_data.dart';
import 'package:points/state_management/notifications/notification_paging_cubit.dart';
import 'package:points/state_management/notifications/notification_unread_count_cubit.dart';
import 'package:points/theme/points_colors.dart' as pointsColors;
import 'package:points/widgets/loader.dart';
import 'package:points/widgets/neumorphic_app_bar_fix.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'notification_widget.dart';

class NotificationsPage extends StatefulWidget {
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  Widget _buildListView(NotificationPagingState state) {
    final notifications = state.notifications;
    return ScrollablePositionedList.builder(
      padding: MediaQuery.of(context).viewPadding + EdgeInsets.only(top: 72),
      itemPositionsListener: itemPositionsListener,
      itemCount: notifications.length + (state.moreToLoad ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (index < notifications.length) {
          final notification = notifications[index];
          final unknownUser = notification.unknownUserId == null
              ? null
              : state.mentionedUsers
                  .firstWhere((user) => user.id == notification.unknownUserId);
          final knownUser = state.mentionedUsers
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

  Widget _buildNoNotifications() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            // There will always be at least one system message
            "No unread notifications :(",
            style: Theme.of(context)
                .textTheme
                .headline5!
                .copyWith(color: Theme.of(context).hintColor),
          ),
        ),
      ),
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
    return BlocBuilder<NotificationPagingCubit, NotificationPagingState>(
      buildWhen: (oldState, newState) {
        return oldState.loading != newState.loading;
      },
      builder: (context, state) {
        return IgnorePointer(
          ignoring: state.loading,
          child: NeumorphicScaffold(
            appBar: NeumorphicAppBar(
              leading: NeumorphicBackButton(
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.circle(),
                ),
              ),
              title: SizedBox(),
              trailing: BlocBuilder<NotificationUnreadCountCubit, int>(
                builder: (context, unreadCount) {
                  return Badge(
                    showBadge: unreadCount > 0,
                    position: BadgePosition(
                      end: -6,
                      top: -6,
                    ),
                    badgeColor: pointsColors.white,
                    badgeContent: Text(unreadCount.toString()),
                    child: NeumorphicButton(
                      tooltip: "Mark all read",
                      child: SizedBox.fromSize(
                        size: Size.square(56),
                        child: Icon(Ionicons.checkmark_done_outline),
                      ),
                      style: NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.circle(),
                      ),
                      onPressed: () {
                        context.read<NotificationPagingCubit>().markAllRead();
                      },
                    ),
                  );
                },
              ),
              secondTrailing:
                  BlocBuilder<NotificationPagingCubit, NotificationPagingState>(
                builder: (context, state) {
                  return NeumorphicButton(
                    tooltip: state.showingRead
                        ? "Show read and unread notifications"
                        : "Only show unread notifications",
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 250),
                      child: Icon(
                        state.showingRead
                            ? Ionicons.eye_off_outline
                            : Ionicons.eye_outline,
                        key: ValueKey(state.showingRead),
                      ),
                    ),
                    style: NeumorphicStyle(
                      boxShape: NeumorphicBoxShape.circle(),
                    ),
                    onPressed: () {
                      context.read<NotificationPagingCubit>().toggleShowRead();
                    },
                  );
                },
              ),
            ),
            extendBodyBehindAppBar: true,
            body: BlocBuilder<NotificationPagingCubit, NotificationPagingState>(
              buildWhen: (oldState, newState) {
                return oldState.notifications != newState.notifications;
              },
              builder: (context, notificationState) {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 400),
                  child: notificationState.notifications.isEmpty
                      ? notificationState.loading
                          ? _buildLoader()
                          : _buildNoNotifications()
                      : _buildListView(notificationState),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _scrollChanged() {
    final pagingCubit = context.read<NotificationPagingCubit>();
    if (!pagingCubit.state.loading) {
      final visible = itemPositionsListener.itemPositions.value;

      // Only happens if the ListView gets an extra item for the Loader
      if (visible.last.index == pagingCubit.state.notifications.length) {
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
