import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_repository/chat_repository.dart';
import 'package:meta/meta.dart';
import 'package:user_repositories/relations_repository.dart';

import '../auth/auth_cubit.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<Notification?> {
  final IRelationsRepository relationsRepository;
  final IChatRepository chatRepository;
  final AuthCubit authCubit;
  late final StreamSubscription _notificationSub;

  NotificationCubit({
    required this.relationsRepository,
    required this.chatRepository,
    required this.authCubit,
  }) : super(null);

  void startListening() {
    _notificationSub = chatRepository.messagesNotificationStream.listen(
      (message) {
        final relations = relationsRepository.currentUserRelations!.all;
        final senderIndex = relations.indexWhere(
          (friend) => friend.id == message.senderId,
        );
        if (senderIndex != -1) {
          final sender = relations[senderIndex];
          emit(MessageNotification(sender, message));
        }
      },
      onError: (_) {
        authCubit.reportConnectionError();
      }
    );
  }

  @override
  Future<void> close() async {
    await _notificationSub.cancel();
    super.close();
  }
}
