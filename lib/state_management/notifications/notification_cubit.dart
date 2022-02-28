import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_repository/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:notification_repository/notification_repository.dart'
    hide Notification;
import 'package:points/helpers/notification_type_icon_data.dart';
import 'package:user_repositories/profile_repository.dart';
import 'package:user_repositories/relations_repository.dart';
import 'package:user_repositories/user_discovery_repository.dart';
import '../../pages/notifications/notification_delegate.dart';

import '../../theme/points_colors.dart' as pointsColors;
import '../../theme/points_icons.dart' as pointsIcons;

import '../auth/auth_cubit.dart';

part 'notification_state.dart';

/// Listens to the [IChatRepository] and [INotificationRepository],
/// for notifications which it emits
/// as a [ChatNotification] or a [Notification],
/// depending on if it is from the [IChatRepository.messagesNotificationStream]
/// or from the [INotificationRepository.notificationStream].
///
/// Also makes sure to emit with the correct icons and colors
/// by fetching/getting the users mentioned in the notifications.
///
/// Uses the [IProfileRepository], [IRelationsRepository],
/// and [IUserDiscoveryRepository] to get the repositories.
///
/// Used only by the [NotificationDelegate].
class NotificationCubit extends Cubit<Notification?> {
  final IChatRepository chatRepository;
  final INotificationRepository notificationRepository;
  final IRelationsRepository relationsRepository;
  final IUserDiscoveryRepository userDiscoveryRepository;
  final IProfileRepository profileRepository;
  final AuthCubit authCubit;
  late final StreamSubscription _messageNotificationSub;
  late final StreamSubscription _notificationSub;

  NotificationCubit({
    required this.chatRepository,
    required this.notificationRepository,
    required this.relationsRepository,
    required this.userDiscoveryRepository,
    required this.profileRepository,
    required this.authCubit,
  }) : super(null);

  /// Start listening to the [IChatRepository] and [INotificationRepository]
  void startListening() {
    _messageNotificationSub = chatRepository.messagesNotificationStream.listen(
      (message) {
        final relations = relationsRepository.currentUserRelations!.all;
        final senderIndex = relations.indexWhere(
          (friend) => friend.id == message.senderId,
        );
        if (senderIndex != -1) {
          final sender = relations[senderIndex];
          emit(
            MessageNotification(
              message.chatId,
              message.senderId,
              icon: pointsIcons.pointsIcons[sender.icon],
              color: pointsColors.colors[sender.color],
              title: sender.name,
              message: message.content,
            ),
          );
        }
      },
      onError: (_) {
        authCubit.reportConnectionError();
      },
    );

    _notificationSub = notificationRepository.notificationStream.listen(
      (notification) async {
        if (notification.type == NotificationType.profileUpdate) {
          return;
        }

        late final IconData? icon;
        if (notification.hasRead) {
          icon = Ionicons.checkmark_circle_outline;
        } else {
          icon = iconDataFromNotificationType(notification.type);
        }

        final firstUser = notification.firstActorId == null
            ? null
            : await _tryToGetUser(notification.firstActorId!);
        final secondUser = notification.secondActorId == null
            ? null
            : await _tryToGetUser(notification.secondActorId!);

        final user = (firstUser ?? secondUser!);

        final unknownName = notification.unknownUserId == null
            ? null
            : (notification.unknownUserId == firstUser?.id
                ? firstUser!.name
                : secondUser!.name);

        final message = notification.getNotificationMessage(unknownName);

        emit(
          Notification(
            id: notification.id,
            important: user.id == notification.selfId ? false : true,
            icon: icon,
            color: user.id == notification.selfId
                ? pointsColors.white
                : pointsColors.colors[user.color],
            message: message,
          ),
        );
      },
      onError: (_) {
        authCubit.reportConnectionError();
      },
    );
  }

  /// Get the profile of a user, either using the [IProfileRepository],
  /// if it is the users own profile,
  /// the [IRelationsRepository] for a related user,
  /// or the [IUserDiscoveryRepository] to fetch it]
  Future<User?> _tryToGetUser(String id) async {
    if (profileRepository.currentProfile?.id == id) {
      return profileRepository.currentProfile!;
    }
    int foundIndex =
        (relationsRepository.currentUserRelations?.all ?? []).indexWhere(
      (user) => user.id == id,
    );
    if (foundIndex != -1) {
      return relationsRepository.currentUserRelations!.all[foundIndex];
    }
    try {
      return userDiscoveryRepository.getUserById(id: id);
    } catch (e) {
      authCubit.reportConnectionError();
    }
  }

  /// If clicked on a notification, mark it as read.
  ///
  /// Handled in the [NotificationDelegate]
  void markAsRead() {
    if (state != null && state!.id != null) {
      final id = state!.id!;
      notificationRepository.markNotificationRead(notificationId: id);
    }
  }

  @override
  Future<void> close() async {
    await _messageNotificationSub.cancel();
    await _notificationSub.cancel();
    super.close();
  }
}
