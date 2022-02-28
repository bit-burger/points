import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_repository/chat_repository.dart';
import 'package:meta/meta.dart';
import 'package:points/state_management/auth/auth_cubit.dart';
import 'package:user_repositories/profile_repository.dart';
import 'package:user_repositories/relations_repository.dart';

part 'chat_state.dart';

/// Handles listening and the paging of a specific chat with another user,
/// even updates the chat if the profile
/// of one of the users in the chat changes.
///
/// The [ChatClosed] state is also emitted,
/// if the two people are no longer friends.
class ChatCubit extends Cubit<ChatState> {
  final IChatRepository chatRepository;
  final IProfileRepository profileRepository;
  final IRelationsRepository relationsRepository;
  final AuthCubit authCubit;
  final String userId;
  final String chatId;

  late final StreamSubscription<Chat> _chatSub;
  late final StreamSubscription<User> _profileSub;
  late final StreamSubscription<UserRelations> _relationsSub;

  ChatCubit({
    required this.userId,
    required this.chatId,
    required this.chatRepository,
    required this.profileRepository,
    required this.relationsRepository,
    required this.authCubit,
  }) : super(InitialChatState());

  /// Initial loading of all messages,
  /// start listening to the [IChatRepository.messagesFromSpecificChat],
  /// for the paging of the chat messages.
  ///
  /// The [IRelationsRepository] and the [IProfileRepository]
  /// are also listened to, to update the chat, if one of the profiles change.
  ///
  /// The [IRelationsRepository] is also listened to,
  /// to make sure that the chat is closed,
  /// if the two people are no longer friends.
  void loadMessages() {
    assert(relationsRepository.currentUserRelations != null);
    assert(state is InitialChatState);

    emit(MessagesFirstFetchLoading());

    chatRepository.listenToSpecificChat(chatId);
    _chatSub = chatRepository.messagesFromSpecificChat!.listen(
      (chat) async {
        if (state is MessagesData) {
          emit(
            (state as MessagesData).copyWith(
              messages: chat.messages,
              allMessagesFetched: chat.allMessagesFetched,
            ),
          );
        } else {
          final currentFriends =
              relationsRepository.currentUserRelations!.friends;

          final relatedUserIndex = currentFriends
              .indexWhere((relatedUser) => relatedUser.id == userId);
          if (relatedUserIndex == -1) {
            await _close();
            return;
          }

          final user = currentFriends[relatedUserIndex];
          emit(
            MessagesData(
              messages: chat.messages,
              allMessagesFetched: chat.allMessagesFetched,
              self: profileRepository.currentProfile!,
              other: user,
            ),
          );
        }
      },
      onError: (error) {
        authCubit.reportConnectionError();
      },
    );

    _profileSub = profileRepository.profileStream.listen((profile) {
      if (state is MessagesData) {
        emit((state as MessagesData).copyWith(self: profile));
      }
    });

    _relationsSub =
        relationsRepository.relationsStream.listen((userRelations) async {
      final relatedUserIndex = userRelations.friends
          .indexWhere((relatedUser) => relatedUser.id == userId);
      if (relatedUserIndex == -1) {
        await _close();
        return;
      }
      if (state is MessagesData) {
        final relatedUser = userRelations.friends[relatedUserIndex];
        if ((state as MessagesData).other != relatedUser) {
          emit((state as MessagesData).copyWith(other: relatedUser));
        }
      }
    });
  }

  void fetchMoreMessages() {
    // because the Cubit is already listening
    // to the paging stream of the chatRepository,
    // it does not have to add the messages
    // to the stream at any time
    chatRepository.fetchMoreMessages();
  }

  void sendMessage(String content) {
    chatRepository.sendMessage(
      chatId: chatId,
      receiverId: userId,
      content: content,
    );
  }

  bool _closed = false;

  Future<void> _close() async {
    emit(ChatClosed());
    await close();
    _closed = true;
  }

  @override
  Future<void> close() async {
    if (!_closed) {
      chatRepository.stopListeningToSpecificChat();
      await _chatSub.cancel();
      await _profileSub.cancel();
      await _relationsSub.cancel();
      await super.close();
    }
  }
}
