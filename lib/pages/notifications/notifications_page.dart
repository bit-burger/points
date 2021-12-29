import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:badges/badges.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide NeumorphicAppBar;
import 'package:ionicons/ionicons.dart';
import 'package:points/helpers/notification_type_icon_data.dart';
import 'package:points/helpers/relations_action_sheet.dart';
import 'package:points/state_management/notifications/notification_paging_cubit.dart';
import 'package:points/state_management/notifications/notification_unread_count_cubit.dart';
import 'package:points/theme/points_colors.dart' as pointsColors;
import 'package:points/widgets/loader.dart';
import 'package:points/widgets/neumorphic_app_bar_fix.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:user_repositories/relations_repository.dart';

import 'notification_widget.dart';

class NotificationsPage extends StatefulWidget {
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  String _statusForRelatedUser(RelatedUser relatedUser) {
    final name = relatedUser.name;
    switch (relatedUser.relationType) {
      case RelationType.friend:
        return "You are currently friends with $name";
      case RelationType.requesting:
        return "$name is currently requesting to be friends with you";
      case RelationType.pending:
        return "You are currently requesting to be friends with $name";
      case RelationType.blocked:
        return "You have currently blocked $name";
      case RelationType.blockedBy:
        return "You are currently blocked by $name";
    }
  }

  Widget _buildListView(NotificationPagingState state) {
    final notifications = state.notifications;
    return ScrollablePositionedList.builder(
      padding: MediaQuery.of(context).viewPadding +
          EdgeInsets.only(
            top: 80,
            bottom: 80,
          ),
      itemPositionsListener: itemPositionsListener,
      itemCount: notifications.length + (state.moreToLoad ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (index < notifications.length) {
          final notification = notifications[index];
          final unknownUser = notification.unknownUserId == null
              ? null
              : state.mentionedUsers
                  .firstWhere((user) => user.id == notification.unknownUserId);
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: NotificationWidget(
              onPressed: () async {
                showRelationsActionSheet(
                  context: context,
                  title: unknownUser == null
                      ? null
                      : unknownUser is RelatedUser
                          ? _statusForRelatedUser(unknownUser)
                          : "You are not currently related with ${unknownUser.name}",
                  actions: [
                    if (unknownUser != null) ...[
                      if (unknownUser is RelatedUser) ...[
                        if (unknownUser.relationType == RelationType.friend)
                          SheetAction(
                            label: "Show profile of friend",
                            key: "show_profile",
                          ),
                        if (unknownUser.relationType == RelationType.requesting)
                          rejectAction,
                        if (unknownUser.relationType == RelationType.pending)
                          cancelAction,
                        if (unknownUser.relationType != RelationType.blocked)
                          blockAction,
                        if (unknownUser.relationType == RelationType.blocked)
                          unblockAction,
                      ],
                      if (unknownUser is! RelatedUser) ...[
                        requestAction,
                        blockAction,
                      ],
                    ],
                    SheetAction(
                      label: "Mark as ${notification.hasRead ? "un" : ""}read",
                      key: "mark_read",
                    ),
                  ],
                  userId: unknownUser?.id,
                  alternativeResultCallback: (result) {
                    switch (result) {
                      case "mark_read":
                        final notificationPagingCubit =
                            context.read<NotificationPagingCubit>();
                        if (notification.hasRead) {
                          notificationPagingCubit.markUnread(
                            notificationId: notification.id,
                          );
                        } else {
                          notificationPagingCubit.markRead(
                            notificationId: notification.id,
                          );
                        }
                        break;
                      case "show_profile":
                        Navigator.of(context).pushNamed(
                          "/friend/${notification.unknownUserId}",
                        );
                        break;
                    }
                  },
                );
              },
              lessSpacing: true,
              icon: iconDataFromNotificationType(notification.type),
              message: notification.getNotificationMessage(unknownUser?.name),
              color: pointsColors.colors[unknownUser?.color ?? 9],
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

  Widget _buildMarkAllNotificationsReadButton() {
    return BlocBuilder<NotificationUnreadCountCubit, int>(
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
    );
  }

  Widget buildShowUnreadNotificationButton() {
    return BlocBuilder<NotificationPagingCubit, NotificationPagingState>(
      buildWhen: (oldState, newState) {
        return oldState.showingRead != newState.showingRead;
      },
      builder: (context, state) {
        return NeumorphicButton(
          tooltip: state.showingRead
              ? "Only show unread notifications"
              : "Show read and unread notifications",
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 250),
            child: Icon(
              // TODO: alternative use of Ionicons.eye_off_outline is possible
              state.showingRead
                  ? Ionicons.mail_unread_outline
                  : Ionicons.mail_outline,
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
              trailing: _buildMarkAllNotificationsReadButton(),
              secondTrailing: buildShowUnreadNotificationButton(),
            ),
            extendBodyBehindAppBar: true,
            body: BlocBuilder<NotificationPagingCubit, NotificationPagingState>(
              buildWhen: (oldState, newState) {
                return oldState.notifications != newState.notifications;
              },
              builder: (context, notificationState) {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
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
