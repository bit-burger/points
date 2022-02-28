import 'dart:async';

import 'package:supabase/supabase.dart';

import 'chat_repository_contract.dart';

import '../errors/messages_error.dart';
import '../domain/message.dart';
import '../domain/chat.dart';

/// Supabase implementation of the [IChatRepository]
class ChatRepository extends IChatRepository {
  final SupabaseClient _client;
  late final String _userId;

  late RealtimeSubscription _messagesNotificationSub;
  late StreamController<Message> _messagesNotificationStreamController;
  Stream<Message> get messagesNotificationStream =>
      _messagesNotificationStreamController.stream;

  String? _specificMessageChatId;
  RealtimeSubscription? _specificMessagesSub;
  StreamController<Chat>? _specificMessagesStreamController;
  Chat? _currentMessagesFromSpecificChat;
  Stream<Chat>? get messagesFromSpecificChat =>
      _specificMessagesStreamController?.stream;

  ChatRepository({required SupabaseClient client}) : _client = client {
    _userId = _client.auth.user()!.id;
    _startListeningToNotificationMessages();
  }

  void _startListeningToNotificationMessages() async {
    _messagesNotificationStreamController = StreamController.broadcast();

    final searchParam = "messages:receiver=eq.$_userId";

    _messagesNotificationSub = _client.from(searchParam).on(
      SupabaseEventTypes.insert,
      (payload) {
        final rawMessage = payload.newRecord!;

        if (rawMessage["chat_id"] != _specificMessageChatId) {
          _messagesNotificationStreamController
              .add(Message.fromJson(rawMessage));
        }
      },
    ).subscribe(
      (_, {String? errorMsg}) {
        if (errorMsg != null) {
          _messagesNotificationStreamController
              .addError(MessageConnectionError());
          close();
        }
      },
    );
  }

  void _addToSpecificChatStream(Chat chat) {
    _currentMessagesFromSpecificChat = chat;
    _specificMessagesStreamController!.add(chat);
  }

  @override
  void listenToSpecificChat(String chatId,
      {int startMaxMessageCount = 30}) async {
    _specificMessagesStreamController = StreamController();
    _specificMessageChatId = chatId;
    try {
      final initialMessages = await _fetchMessages(
        chatId: chatId,
        limit: startMaxMessageCount,
      );
      _addToSpecificChatStream(
        Chat(
          initialMessages,
          initialMessages.length < startMaxMessageCount,
        ),
      );
    } on MessageConnectionError catch (e) {
      _specificMessagesStreamController!.addError(e);
      close();
      return;
    }

    final searchParam = "messages:chat_id=eq.$chatId";

    this._specificMessagesSub = _client.from(searchParam)
        // .on(SupabaseEventTypes.delete, (payload) {
        // final int id = payload.oldRecord!["id"]!;
        //
        // _addToSpecificChatStream([..._currentMessagesFromSpecificChat!]
        //   ..removeWhere((message) => message.id == id));
        // })
        .on(
      SupabaseEventTypes.insert,
      (payload) {
        final rawMessage = payload.newRecord!;
        final message = Message.fromJson(rawMessage);

        _addToSpecificChatStream(
          _currentMessagesFromSpecificChat!.copyWithMessages(
            [message, ..._currentMessagesFromSpecificChat!.messages],
          ),
        );
      },
    ).subscribe(
      (_, {String? errorMsg}) {
        if (errorMsg != null) {
          _specificMessagesStreamController?.addError(MessageConnectionError());
          close();
        }
      },
    );
  }

  @override
  void fetchMoreMessages({int howMany = 20}) async {
    if (_currentMessagesFromSpecificChat!.allMessagesFetched) {
      return;
    }

    if (_specificMessagesSub != null) {
      try {
        final messages = await _fetchMessages(
          chatId: _specificMessageChatId!,
          limit: howMany,
          offset: _currentMessagesFromSpecificChat!.messages.length,
        );
        _addToSpecificChatStream(
          Chat(
            [
              ..._currentMessagesFromSpecificChat!.messages,
              ...messages,
            ],
            messages.length < howMany,
          ),
        );
      } on MessageConnectionError catch (e) {
        _specificMessagesStreamController!.addError(e);
        close();
      }
    }
  }

  @override
  void stopListeningToSpecificChat() {
    if (_specificMessagesSub != null) {
      _client.removeSubscription(_specificMessagesSub!);
      _specificMessagesStreamController!.close();

      _specificMessagesSub = null;
      _specificMessagesStreamController = null;
      _specificMessageChatId = null;
      _currentMessagesFromSpecificChat = null;
    }
  }

  // TODO: Instead of offset use timestamp of last message
  Future<List<Message>> _fetchMessages({
    required String chatId,
    required int limit,
    int? offset,
  }) async {
    final query = _client
        .from("messages")
        .select("sender, receiver, content, created_at")
        .eq("chat_id", chatId)
        .order("created_at");

    if (offset != null) {
      query.range(offset, offset + limit - 1);
    } else {
      query.limit(limit);
    }

    final response = await query.execute();

    if (response.error != null) {
      throw MessageConnectionError();
    }

    final rawMessages = response.data as List;
    final messages = rawMessages
        .map<Message>(
          (rawMessage) => Message.fromJson(
            rawMessage,
            chatId: chatId,
          ),
        )
        .toList();
    return messages;
  }

  @override
  void close() {
    _client.removeSubscription(_messagesNotificationSub);
    _messagesNotificationStreamController.close();
    if (_specificMessagesSub != null) {
      _specificMessagesStreamController!.close();
      _client.removeSubscription(_specificMessagesSub!);
    }
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String content,
  }) async {
    final response = await _client.rpc("send_message", params: {
      "chat_id": chatId,
      "other_id": receiverId,
      "content": content,
    }).execute();

    if (response.error != null) {
      throw MessageConnectionError();
    }
  }
}
