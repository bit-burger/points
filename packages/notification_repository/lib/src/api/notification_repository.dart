import 'dart:async';

import 'package:supabase/supabase.dart';

import '../domain/notification.dart';
import '../domain/notifications.dart';
import '../errors/notification_connection_error.dart';

import 'notification_repository_contract.dart';

class NotificationRepository implements INotificationRepository {
  final SupabaseClient _client;
  final String _userId;

  /// Always needed
  late RealtimeSubscription _notificationsInsertSub;

  /// Only needed when there is an active [notificationsPagingStream]
  RealtimeSubscription? _notificationsUpdateSub;

  /// Everything related to the [notificationsPagingStream]
  ///
  /// Are either all null or all have a value
  StreamController<Notifications>? _notificationsPagingStreamController;
  Notifications? _currentNotifications;
  Stream<Notifications>? get notificationsPagingStream =>
      _notificationsPagingStreamController?.stream;

  /// Everything related to the [notificationStream]
  late StreamController<Notification> _notificationStreamController;
  Stream<Notification> get notificationStream =>
      _notificationStreamController.stream;

  NotificationRepository({
    required SupabaseClient client,
  })  : _client = client,
        _userId = client.auth.currentUser!.id {
    _startListening();
  }

  /// Start listening to inserts for the [notificationStream]
  void _startListening() {
    _notificationStreamController = StreamController.broadcast();

    _notificationsInsertSub = _client
        .from('notifications:user_id=eq.$_userId')
        .on(SupabaseEventTypes.insert, (payload) {
      final newNotification = Notification.fromJson(payload.newRecord!);

      if (_notificationsPagingStreamController != null) {
        _currentNotifications = _currentNotifications!.copyWith(
          earlierNotification: newNotification,
        );
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
  }

  @override
  void startListeningToPagingStream({
    bool onlyUnread = false,
    int startMaxNotificationCount = 30,
  }) async {
    _notificationsPagingStreamController = StreamController();
    _currentNotifications = Notifications([], false);

    try {
      final initialNotifications = await _fetchNotifications(
        limit: startMaxNotificationCount,
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

    _notificationsUpdateSub =
        _client.from('notifications:user_id=eq.$_userId').on(
      SupabaseEventTypes.update,
      (payload) {
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
      );

      _currentNotifications = _currentNotifications!.copyWith(
        olderNotifications: notifications,
        allNotificationsFetched: notifications.length < howMany,
      );
      _notificationsPagingStreamController!.add(_currentNotifications!);
    } on NotificationConnectionError catch (e) {
      _notificationsPagingStreamController!.addError(e);
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
  Future<void> markAllNotificationsRead() async {
    // final response = await _client.rpc('mark_all_messages_read').execute();
    //
    // if (response.error != null) {
    //   throw NotificationConnectionError();
    // }
    throw UnimplementedError(
      "Cannot be implemented due to supabase limitations",
    );
  }

  @override
  void stopListeningToPagingStream() {
    if (_notificationsPagingStreamController != null) {
      _notificationsPagingStreamController?.close();

      _client.removeSubscription(_notificationsUpdateSub!);

      _notificationsPagingStreamController = null;
      _currentNotifications = null;
      _notificationsUpdateSub = null;
    }
  }

  Future<List<Notification>> _fetchNotifications({
    required int limit,
    DateTime? after,
  }) async {
    final query = _client.from('notifications').select().eq("user_id", _userId);
    if (after != null) {
      query.lt("created_at", after);
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
    stopListeningToPagingStream();
    _client.removeSubscription(_notificationsInsertSub);
    _notificationStreamController.close();
    _notificationsPagingStreamController = null;
  }
}
