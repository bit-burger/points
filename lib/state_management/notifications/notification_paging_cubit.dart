import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:notification_repository/notification_repository.dart';
import 'package:points/state_management/auth/auth_cubit.dart';
import 'package:user_repositories/profile_repository.dart';
import 'package:user_repositories/relations_repository.dart';
import 'package:user_repositories/user_discovery_repository.dart';

part 'notification_paging_state.dart';

/// Handles listening and the paging of the notifications,
/// even updates the appearance to the notifications,
/// if the friends change, by listening to the [IRelationsRepository].
class NotificationPagingCubit extends Cubit<NotificationPagingState> {
  final INotificationRepository notificationRepository;
  final IRelationsRepository relationsRepository;
  final IUserDiscoveryRepository userDiscoveryRepository;
  final IProfileRepository profileRepository;
  final AuthCubit authCubit;

  late StreamSubscription _notificationPagingSub;
  late final StreamSubscription _relationsSub;

  List<User> _userCache = [];

  NotificationPagingCubit({
    required this.notificationRepository,
    required this.authCubit,
    required this.relationsRepository,
    required this.userDiscoveryRepository,
    required this.profileRepository,
  }) : super(
          NotificationPagingState(
            rawNotifications: [],
            moreToLoad: false,
            mentionedUsers: [],
            loading: true,
          ),
        );

  void startListening() {
    // relations
    _relationsSub = relationsRepository.relationsStream.listen((_) {
      _emitNotifications(state.rawNotifications, state.moreToLoad);
    });

    // notifications
    notificationRepository.startListeningToPagingStream();
    _notificationPagingSub =
        notificationRepository.notificationsPagingStream!.listen(
      _onReceiveNotifications,
      onError: (e) {
        authCubit.reportConnectionError();
      },
    );
  }

  void _onReceiveNotifications(Notifications notifications) {
    _emitNotifications(
      notifications.notifications,
      !notifications.allNotificationsFetched,
    );
  }

  void toggleShowRead() {
    emit(
      NotificationPagingState(
        rawNotifications: [],
        moreToLoad: false,
        mentionedUsers: [],
        loading: true,
        showingRead: !state.showingRead,
      ),
    );
    notificationRepository.startListeningToPagingStream(
      onlyUnread: !state.showingRead,
    );
    _notificationPagingSub =
        notificationRepository.notificationsPagingStream!.listen(
      _onReceiveNotifications,
      onError: (e) {
        authCubit.reportConnectionError();
      },
    );
  }

  void loadMore() {
    notificationRepository.fetchMoreNotifications();
    emit(state.copyWith(loading: true));
  }

  void _emitNotifications(
    List<Notification> notifications,
    bool moreToLoad,
  ) async {
    final activeUsers = [
      profileRepository.currentProfile!,
      ...(relationsRepository.currentUserRelations!).all,
      ..._userCache,
    ];
    final activeUserIdsSet = activeUsers.map<String>((user) => user.id).toSet();
    final userSearches = <Future<User>>[];

    for (final notification in notifications) {
      if (notification.unknownUserId != null &&
          !activeUserIdsSet.contains(notification.unknownUserId)) {
        userSearches.add(
          userDiscoveryRepository.getUserById(
            id: notification.unknownUserId!,
          ),
        );
      }
    }

    if (userSearches.isNotEmpty) {
      try {
        final fetchedUsers = await Future.wait(userSearches, eagerError: true);
        activeUsers.addAll(fetchedUsers);
        _userCache.addAll(fetchedUsers);
      } on PointsError catch (_) {
        authCubit.reportConnectionError();
        return;
      }
    }

    emit(
      state.copyWith(
        rawNotifications: notifications,
        moreToLoad: moreToLoad,
        mentionedUsers: activeUsers,
        loading: false,
      ),
    );
  }

  void markAllRead() {
    notificationRepository.markAllNotificationsRead();
  }

  void markRead({required int notificationId}) {
    notificationRepository.markNotificationRead(notificationId: notificationId);
  }

  void markUnread({required int notificationId}) {
    notificationRepository.markNotificationUnread(
        notificationId: notificationId);
  }

  @override
  Future<void> close() async {
    notificationRepository.stopPagingStream();
    await _notificationPagingSub.cancel();
    await _relationsSub.cancel();
    return super.close();
  }
}
