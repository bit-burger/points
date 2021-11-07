import 'dart:async';

import 'package:chat_repository/src/errors/messages_error.dart';

import 'chat_repository_contract.dart';
import '../domain/message.dart';
import 'package:supabase/supabase.dart';

class ChatRepository extends IChatRepository {
  final SupabaseClient _client;
  late final String _userId;
  ChatRepository({required SupabaseClient client}) : _client = client {
    _userId = _client.auth.user()!.id;
  }

  @override
  Stream<List<Message>> messageStreamToUserId(
      {required String otherId, int startingLimit = 20}) async* {
    final chatId = await _fetchChatId(otherId);
    final initialMessages = await _fetchMessages(chatId, startingLimit);

    yield initialMessages;

    late final StreamController<Message> messageStreamController;
    late final RealtimeSubscription subscription;

    messageStreamController = StreamController<Message>(onCancel: () {
      if (!messageStreamController.hasListener) {
        _client.removeSubscription(subscription);
        messageStreamController.close();
      }
    });

    List<Message> lastMessages = initialMessages;

    final searchParam = "messages:id=eq.$chatId";

    subscription =
        _client.from(searchParam).on(SupabaseEventTypes.delete, (payload) {
      lastMessages = [...lastMessages];
      final int id = payload.oldRecord!["id"]!;

      lastMessages.removeWhere((message) => message.id == id);
    }).on(SupabaseEventTypes.insert, (payload) {
      final rawMessage = payload.newRecord!;
      final message = Message.fromJson(rawMessage, _userId);

      lastMessages = [message, ...lastMessages];
    }).subscribe(
      (_, {String? errorMsg}) {
        if (errorMsg != null) {
          messageStreamController.addError(MessageConnectionError());
          messageStreamController.close();
        }
      },
    );
  }

  Future<int> _fetchChatId(String otherId) async {
    final response = await _client
        .from("messages")
        .select("id")
        .eq("sender", _userId)
        .eq("receiver", otherId)
        .single()
        .execute();

    if (response.error != null) {
      throw MessageConnectionError();
    }

    return response.data["id"]!;
  }

  Future<List<Message>> _fetchMessages(int chatId, int limit) async {
    final response = await _client
        .from("messages")
        .select("id, sender, receiver, created_at, content")
        .eq("chat_id", chatId)
        .order("createdAt")
        .limit(limit)
        .execute();

    if (response.error != null) {
      throw MessageConnectionError();
    }

    final rawMessages = response.data as List;
    final messages = rawMessages
        .map<Message>((rawMessage) => Message.fromJson(rawMessage, _userId))
        .toList();
    return messages;
  }
}
