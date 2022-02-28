import 'dart:async';

import 'package:supabase/supabase.dart';

import '../domain/notification.dart';
import '../domain/notifications.dart';
import '../errors/notification_connection_error.dart';

import 'notification_repository_contract.dart';

/// Supabase implementation of [INotificationRepository]
class NotificationRepository implements INotificationRepository {
  final SupabaseClient _client;
  final String _userId;

  /// Always needed
  late RealtimeSubscription _notificationsInsertSub;

  /// Only needed when there is an active [notificationsPagingStream]
  RealtimeSubscription? _notificationsUpdateSub;

  /// Everything related to the [notificationUnreadCountStream]
  late final StreamController<int> _notificationUnreadCountStreamController;
  Stream<int> get notificationUnreadCountStream =>
      _notificationUnreadCountStreamController.stream;
  int _currentUnreadCount = 0;
  void _addToCurrentUnreadCount(int newCount) {
    if (newCount != 0) {
      _currentUnreadCount += newCount;
      _notificationUnreadCountStreamController.add(_currentUnreadCount);
    }
  }

  /// Everything related to the [notificationsPagingStream]
  ///
  /// Are either all null or all have a value
  StreamController<Notifications>? _notificationsPagingStreamController;
  Notifications? _currentNotifications;
  bool? _onlyUnread;
  Stream<Notifications>? get notificationsPagingStream =>
      _notificationsPagingStreamController?.stream;

  /// Everything related to the [notificationStream]
  late final StreamController<Notification> _notificationStreamController;
  Stream<Notification> get notificationStream =>
      _notificationStreamController.stream;

  NotificationRepository({
    required SupabaseClient client,
  })  : _client = client,
        _userId = client.auth.currentUser!.id {
    _startListening();
  }

  void _startListeningUnreadCount() async {
    _notificationUnreadCountStreamController = StreamController.broadcast();

    final response = await _client.rpc("all_unread_messages_count").execute();
    if (response.error != null) {
      _notificationUnreadCountStreamController.addError(
        NotificationConnectionError(),
      );
      return;
    }
    _addToCurrentUnreadCount(response.data);
  }

  /// Start listening to inserts for the [notificationStream]
  void _startListening() {
    _startListeningUnreadCount();

    _notificationStreamController = StreamController.broadcast();

    _notificationsInsertSub = _client
        .from('notifications:user_id=eq.$_userId')
        .on(SupabaseEventTypes.insert, (payload) {
      final newNotification = Notification.fromJson(payload.newRecord!);

      // Update unread count by one if the new notification is unread
      if (!newNotification.hasRead) {
        _addToCurrentUnreadCount(1);
      }

      // add it to the paging stream if there is one,
      // if not add it to the normal notification stream
      if (_notificationsPagingStreamController != null) {
        _currentNotifications = _currentNotifications!.copyWith(
          earlierNotification: newNotification,
        );
        if (_onlyUnread! && newNotification.hasRead == true) {
          return;
        }
        _notificationsPagingStreamController!.add(_currentNotifications!);
      } else {
        _notificationStreamController.add(newNotification);
      }
    }).subscribe(
      (_, {String? errorMsg}) {
        if (errorMsg != null) {
          _notificationStreamController.addError(
            NotificationConnectionError(),
          );
          close();
        }
      },
    );

    _notificationsUpdateSub =
        _client.from('notifications:user_id=eq.$_userId').on(
      SupabaseEventTypes.update,
      (payload) {
        // update the count stream if necessary
        final oldUnreadCountValue = payload.oldRecord!["has_read"] ? 0 : 1;
        final newUnreadCountValue = payload.newRecord!["has_read"] ? 0 : 1;
        final unreadCountValueDelta = newUnreadCountValue - oldUnreadCountValue;
        _addToCurrentUnreadCount(unreadCountValueDelta);

        // if there is a paging stream, update the paging stream
        if (_notificationsPagingStreamController != null) {
          final updatedNotification = Notification.fromJson(payload.newRecord!);

          final updatedNotifications =
              _currentNotifications!.notifications.map<Notification>(
            (notification) {
              if (notification.id == updatedNotification.id) {
                return updatedNotification;
              } else {
                return notification;
              }
            },
          ).toList(growable: false);

          _currentNotifications = Notifications(
            updatedNotifications,
            _currentNotifications!.allNotificationsFetched,
          );
          _notificationsPagingStreamController!.add(_currentNotifications!);
        }
      },
    ).subscribe(
      (_, {String? errorMsg}) {
        if (errorMsg != null) {
          _notificationsPagingStreamController?.addError(
            NotificationConnectionError(),
          );
          close();
        }
      },
    );
  }

  @override
  void startListeningToPagingStream({
    bool onlyUnread = false,
    int startMaxNotificationCount = 30,
  }) async {
    _onlyUnread = onlyUnread;
    _notificationsPagingStreamController = StreamController();
    _currentNotifications = Notifications([], false);

    try {
      final initialNotifications = await _fetchNotifications(
        limit: startMaxNotificationCount,
        onlyUnread: onlyUnread,
      );

      // In case when in the short amount of time between
      // when the notifications are requested and come back,
      // there the insert listener catches a notification
      // and puts it inside _currentNotifications
      _currentNotifications = _currentNotifications!.copyWith(
        olderNotifications: initialNotifications,
        allNotificationsFetched:
            initialNotifications.length < startMaxNotificationCount,
      );

      _notificationsPagingStreamController!.add(_currentNotifications!);
    } on NotificationConnectionError catch (e) {
      throw e;
    }
  }

  @override
  void fetchMoreNotifications({int howMany = 20}) async {
    if (_notificationsPagingStreamController == null) {
      return;
    }
    try {
      final notifications = await _fetchNotifications(
        limit: howMany,
        after: _currentNotifications!.notifications.length == 0
            ? null
            : _currentNotifications!.notifications.last.createdAt,
        onlyUnread: _onlyUnread!,
      );

      _currentNotifications = _currentNotifications!.copyWith(
        olderNotifications: notifications,
        allNotificationsFetched: notifications.length < howMany,
      );
      _notificationsPagingStreamController!.add(_currentNotifications!);
    } on NotificationConnectionError catch (e) {
      _notificationsPagingStreamController?.addError(e);
      close();
    }
  }

  @override
  Future<void> markNotificationRead({required int notificationId}) async {
    final response = await _client.rpc(
      'mark_message_read',
      params: {"message_id": notificationId},
    ).execute();

    if (response.error != null) {
      throw NotificationConnectionError();
    }
  }

  @override
  Future<void> markNotificationUnread({required int notificationId}) async {
    final response = await _client.rpc(
      'mark_message_unread',
      params: {"message_id": notificationId},
    ).execute();

    if (response.error != null) {
      throw NotificationConnectionError();
    }
  }

  @override
  Future<void> markAllNotificationsRead() async {
    final response = await _client.rpc('mark_all_messages_read').execute();

    if (response.error != null) {
      throw NotificationConnectionError();
    }
  }

  @override
  void stopPagingStream() {
    if (_notificationsPagingStreamController != null) {
      _notificationsPagingStreamController?.close();

      _onlyUnread = null;
      _notificationsPagingStreamController = null;
      _currentNotifications = null;
    }
  }

  Future<List<Notification>> _fetchNotifications({
    required int limit,
    required bool onlyUnread,
    DateTime? after,
  }) async {
    final query = _client.from('notifications').select().eq("user_id", _userId);

    if (after != null) {
      query.lt("created_at", after);
    }
    if (onlyUnread) {
      query.eq("has_read", false);
    }
    query.order('created_at').limit(limit);

    final response = await query.execute();
    if (response.error != null) {
      throw NotificationConnectionError();
    }
    final rawMessages = response.data as List;
    final messages = rawMessages
        .map((rawMessage) => Notification.fromJson(rawMessage))
        .toList();

    return messages;
  }

  @override
  void close() {
    stopPagingStream();

    _client.removeSubscription(_notificationsInsertSub);
    _client.removeSubscription(_notificationsUpdateSub!);

    _notificationStreamController.close();
    _notificationUnreadCountStreamController.close();
  }
}
