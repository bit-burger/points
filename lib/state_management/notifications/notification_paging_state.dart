part of 'notification_paging_cubit.dart';

class NotificationPagingState {
  final List<User> mentionedUsers;
  final List<Notification> rawNotifications;
  final bool moreToLoad;
  final bool loading;
  final bool showingRead;

  List<Notification> get notifications {
    if (showingRead) {
      return rawNotifications;
    }
    return rawNotifications
        .where((notification) => !notification.hasRead)
        .toList();
  }

  NotificationPagingState({
    required this.rawNotifications,
    required this.moreToLoad,
    required this.mentionedUsers,
    this.loading = false,
    this.showingRead = true,
  });

  NotificationPagingState copyWith({
    List<User>? mentionedUsers,
    List<Notification>? rawNotifications,
    bool? moreToLoad,
    bool? loading,
    bool? showingRead,
  }) {
    return NotificationPagingState(
      mentionedUsers: mentionedUsers ?? this.mentionedUsers,
      rawNotifications: rawNotifications ?? this.rawNotifications,
      moreToLoad: moreToLoad ?? this.moreToLoad,
      loading: loading ?? this.loading,
      showingRead: showingRead ?? this.showingRead,
    );
  }
}
