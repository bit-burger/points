import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:notification_repository/notification_repository.dart';
import 'package:points/state_management/auth/auth_cubit.dart';

/// Listens to and emits
/// the [INotificationRepository.notificationUnreadCountStream],
/// for the amount of unread notifications in realtime.
///
/// Used in multiple pages.
class NotificationUnreadCountCubit extends Cubit<int> {
  final INotificationRepository notificationRepository;
  final AuthCubit authCubit;
  late final StreamSubscription _sub;

  NotificationUnreadCountCubit({
    required this.notificationRepository,
    required this.authCubit,
  }) : super(0);

  void startListening() async {
    _sub = notificationRepository.notificationUnreadCountStream.listen(
      (unreadCount) {
        emit(unreadCount);
      },
      onError: (e) {
        authCubit.reportConnectionError();
      },
    );
  }

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}
