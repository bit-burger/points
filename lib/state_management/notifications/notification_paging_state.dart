part of 'notification_paging_cubit.dart';

@immutable
abstract class NotificationPagingState {}

class NotificationPagingInitial extends NotificationPagingState {}

class NotificationPagingDataLoading extends NotificationPagingState {}

class NotificationPagingData extends NotificationPagingState {
  final List<User> mentionedUsers;
  final List<Notification> notifications;
  final bool moreToLoad;

  NotificationPagingData(
    this.notifications,
    this.moreToLoad,
    this.mentionedUsers,
  );
}

class LoadingMoreNotifications extends NotificationPagingState {}
