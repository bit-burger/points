import '../domain/notification.dart';
import '../domain/notifications.dart';

/// Repository for listening to notifications,
/// paging through them, and marking them as read
abstract class INotificationRepository {
  /// Broadcasts each [Notification] that comes in,
  /// except when the is an active session
  /// listening to the [notificationsPagingStream]
  Stream<Notification> get notificationStream;

  /// If this stream is set (and not null),
  /// the [notificationStream] will not broadcast any new [Notification]s.
  ///
  /// This stream allows you to listen
  /// to new [Notifications] as well as their changes,
  /// while being able to page through older notifications
  ///
  /// The [Notifications] class features a [List] of [Notification]s,
  /// as well if there are more to fetch
  Stream<Notifications>? get notificationsPagingStream;

  /// Start the [notificationsPagingStream] and
  /// stop broadcasting to the notificationStream
  void startListeningToPagingStream({
    bool onlyUnread = false,
    int startMaxNotificationCount = 30,
  });

  /// If there is a active [notificationsPagingStream],
  /// fetch more Notifications and
  /// add them to the [notificationsPagingStream].
  ///
  /// Errors will be added to the [notificationsPagingStream]
  void fetchMoreNotifications({int howMany = 20});

  /// Mark a single [Notification] with the id of [notificationId] as read
  Future<void> markNotificationRead({required int notificationId});

  /// Mark every single [Notification] as read
  Future<void> markAllNotificationsRead();

  // TODO: Possible feature
  // /// Delete a [Notification] with the id of [notificationId] as read
  // Future<void> deleteNotification();

  /// Cancel all subscriptions,
  /// that are needed for the [notificationsPagingStream],
  /// delete the cache of [Notification]s and
  /// set the stream to null
  void stopListeningToPagingStream();

  /// Cleanup
  void close();
}
