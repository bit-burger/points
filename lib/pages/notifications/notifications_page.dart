import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart' hide Notification;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide NeumorphicAppBar, Notification;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:notification_repository/notification_repository.dart';
import 'package:points/helpers/notification_type_icon_data.dart';
import 'package:points/helpers/relations_action_sheet.dart';
import 'package:points/state_management/notifications/notification_paging_cubit.dart';
import 'package:points/state_management/notifications/notification_unread_count_cubit.dart';
import 'package:points/theme/points_colors.dart' as pointsColors;
import 'package:points/widgets/loader.dart';
import 'package:points/widgets/neumorphic_app_bar_fix.dart';
import 'package:points/widgets/neumorphic_action.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:user_repositories/relations_repository.dart';

import '../../widgets/notification_widget.dart';

class NotificationsPage extends StatefulWidget {
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  String? _dateToString(DateTime date) {
    final now = DateTime.now();
    final difference = DateTime(now.year, now.month, now.day).difference(
      DateTime(date.year, date.month, date.day),
    );
    late final formatString;
    if (difference.inDays == 0) {
      return null;
    } else if (difference.inDays == 1) {
      return "yesterday";
    } else if (difference.inDays < 7) {
      formatString = "EEEE";
    } else if (difference.inDays < 160) {
      formatString = "EEE, MMM d";
    } else {
      formatString = "EEE, MMM d, y";
    }
    return DateFormat(formatString).format(date).toLowerCase();
  }

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

  Widget _buildSlidableAction(Notification notification) {
    return Expanded(
      child: SizedBox.expand(
        child: Padding(
          padding: EdgeInsets.only(right: 20),
          child: Center(
            child: Builder(
              builder: (context) {
                return CupertinoButton(
                  child: Icon(
                    notification.hasRead
                        ? Ionicons.close_outline
                        : Ionicons.checkmark_outline,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Slidable.of(context)!.close();
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
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationActions(
    Notification notification,
    User? notificationUnknownUser,
  ) {
    showRelationsActionSheet(
      context: context,
      title: notificationUnknownUser == null
          ? null
          : notificationUnknownUser is RelatedUser
              ? _statusForRelatedUser(notificationUnknownUser)
              : "You are not currently related with ${notificationUnknownUser.name}",
      actions: [
        if (notificationUnknownUser != null) ...[
          if (notificationUnknownUser is RelatedUser) ...[
            if (notificationUnknownUser.relationType == RelationType.friend)
              SheetAction(
                label: "Show profile",
                key: "show_profile",
              ),
            if (notificationUnknownUser.relationType == RelationType.requesting)
              acceptAction,
            if (notificationUnknownUser.relationType == RelationType.requesting)
              rejectAction,
            if (notificationUnknownUser.relationType == RelationType.pending)
              cancelAction,
            if (notificationUnknownUser.relationType != RelationType.blocked)
              blockAction,
            if (notificationUnknownUser.relationType == RelationType.blocked)
              unblockAction,
          ],
          if (notificationUnknownUser is! RelatedUser) ...[
            requestAction,
            blockAction,
          ],
        ],
        SheetAction(
          label: "Mark as ${notification.hasRead ? "un" : ""}read",
          key: "mark_read",
        ),
      ],
      userId: notificationUnknownUser?.id,
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
              "/friend/${notificationUnknownUser?.id}",
            );
            break;
        }
      },
    );
  }

  Widget _buildNotification(
    NotificationPagingState state,
    Notification notification,
  ) {
    final unknownUser = notification.unknownUserId == null
        ? null
        : state.mentionedUsers
            .firstWhere((user) => user.id == notification.unknownUserId);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: NotificationWidget(
        date: notification.createdAt,
        onPressed: () => _showNotificationActions(notification, unknownUser),
        lessSpacing: true,
        icon: iconDataFromNotificationType(notification.type),
        message: notification.getNotificationMessage(unknownUser?.name),
        color: pointsColors.colors[unknownUser?.color ?? 9],
        read: notification.hasRead,
      ),
    );
  }

  Widget _buildNotificationsList(NotificationPagingState state) {
    final notifications = state.notifications;
    return GroupedListView<Notification, DateTime>(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      order: GroupedListOrder.DESC,
      groupBy: (Notification notification) {
        final date = notification.createdAt;
        return DateTime(date.year, date.month, date.day);
      },
      itemComparator: (first, second) =>
          first.createdAt.compareTo(second.createdAt),
      elements: notifications,
      padding: MediaQuery.of(context).viewPadding +
          EdgeInsets.only(
            top: 80,
            bottom: 80,
          ),
      groupHeaderBuilder: (Notification notification) {
        final displayDate = _dateToString(notification.createdAt);
        if (displayDate == null) {
          return SizedBox();
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              displayDate,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
      itemBuilder: (BuildContext context, Notification notification) {
        return Slidable(
          closeOnScroll: true,
          endActionPane: ActionPane(
            extentRatio: 72 / MediaQuery.of(context).size.width,
            motion: ScrollMotion(),
            children: [
              _buildSlidableAction(notification),
            ],
          ),
          child: _buildNotification(state, notification),
        );
      },
    );
  }

  Widget _buildLoadingList(NotificationPagingState state) {
    final children = [
      _buildNotificationsList(state),
      if (state.moreToLoad) _buildLoader(),
    ];
    return SlidableAutoCloseBehavior(
      child: ScrollablePositionedList.builder(
        itemPositionsListener: _itemPositionsListener,
        itemCount: children.length,
        itemBuilder: (_, i) => children[i],
      ),
    );
  }

  Widget _buildEmptyNotifications() {
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
        return NeumorphicAction(
          badgeNotifications: unreadCount,
          tooltip: "Mark all read",
          child: Icon(Ionicons.checkmark_done_outline),
          onPressed: () {
            context.read<NotificationPagingCubit>().markAllRead();
          },
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
        return NeumorphicAction(
          tooltip: state.showingRead
              ? "Only show unread notifications"
              : "Show read and unread notifications",
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 250),
            child: Icon(
              // TODO: alternative use of Ionicons.eye_off_outline is possible
              state.showingRead
                  ? Ionicons.mail_unread_outline
                  : Ionicons.mail_open_outline,
              key: ValueKey(state.showingRead),
            ),
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
              leading: NeumorphicAction.backButton(),
              title: SizedBox(),
              trailing: _buildMarkAllNotificationsReadButton(),
              secondTrailing: buildShowUnreadNotificationButton(),
            ),
            extendBodyBehindAppBar: true,
            body: BlocBuilder<NotificationPagingCubit, NotificationPagingState>(
              buildWhen: (oldState, newState) {
                return oldState.notifications != newState.notifications ||
                    oldState.mentionedUsers != newState.mentionedUsers;
              },
              builder: (context, notificationState) {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: notificationState.notifications.isEmpty
                      ? notificationState.loading
                          ? _buildLoader()
                          : _buildEmptyNotifications()
                      : _buildLoadingList(notificationState),
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
      final visibleItems = _itemPositionsListener.itemPositions.value;

      // Only happens if the ScrollablePositionedListView gets an extra item,
      // because of the Loader
      if (visibleItems.last.index == 1) {
        pagingCubit.loadMore();
      }
    }
  }

  @override
  void initState() {
    _itemPositionsListener.itemPositions.addListener(_scrollChanged);
    super.initState();
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_scrollChanged);
    super.dispose();
  }
}
