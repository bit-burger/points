import 'package:async/async.dart';
import 'package:chat_repository/src/errors/messages_error.dart';
import 'package:faker/faker.dart';

import 'package:supabase_testing_utils/supabase_testing_utils.dart';
import 'package:test/test.dart';

import 'message_matcher.dart';

void main() {
  late LoggedInUser user1;
  late LoggedInUser user2;
  late String chatId;

  setUp(() async {
    user1 = await LoggedInUser.get();
    user2 = await LoggedInUser.get();

    final relationsQueue1 = StreamQueue(user1.relations.relationsStream);
    final relationsQueue2 = StreamQueue(user2.relations.relationsStream);

    // Make sure both the users are friends
    if (user1.relations.currentUserRelations == null) {
      await relationsQueue1.next;
    }

    if (user2.relations.currentUserRelations == null) {
      await relationsQueue2.next;
    }

    user1.relations.request(user2.id);
    await relationsQueue1.next;
    await relationsQueue2.next;

    user2.relations.accept(user1.id);
    await relationsQueue1.next;
    await relationsQueue2.next;

    chatId = user1.relations.currentUserRelations!.friends[0].chatId;
  });

  test("Test notifications", () async {
    final messageContent = faker.lorem.sentence();

    final longMessageContent = faker.lorem.sentences(10).reduce(
          (value, element) => value + element,
        );

    expect(
      user2.chat.messagesNotificationStream,
      emitsInOrder(
        [
          MessageMatcher(
            chatId: chatId,
            content: messageContent,
            senderId: user1.id,
            receiverId: user2.id,
          ),
          MessageMatcher(
            chatId: chatId,
            content: longMessageContent,
            senderId: user1.id,
            receiverId: user2.id,
          ),
        ],
      ),
    );

    user1.chat.sendMessage(
      chatId: chatId,
      receiverId: user2.id,
      content: messageContent,
    );

    await Future.delayed(Duration(seconds: 1));

    user1.chat.sendMessage(
      chatId: chatId,
      receiverId: user2.id,
      content: longMessageContent,
    );
  });

  test("Sending messages between two users", () async {
    user1.chat.listenToSpecificChat(chatId);
    final messageQueue1 = StreamQueue(user1.chat.messagesFromSpecificChat!);
    final user1Messages1 = await messageQueue1.next;
    expect(user1Messages1.allMessagesFetched, true);
    expect(user1Messages1.messages, []);

    user2.chat.listenToSpecificChat(chatId);
    final messageQueue2 = StreamQueue(user2.chat.messagesFromSpecificChat!);
    final user2Messages1 = await messageQueue2.next;
    expect(user2Messages1.allMessagesFetched, true);
    expect(user2Messages1.messages, []);

    final messageContent = faker.lorem.sentence();
    user1.chat.sendMessage(
      chatId: chatId,
      receiverId: user2.id,
      content: messageContent,
    );

    final expectedMessage = MessageMatcher(
      chatId: chatId,
      content: messageContent,
      senderId: user1.id,
      receiverId: user2.id,
    );

    final user1Messages2 = await messageQueue1.next;
    expect(user1Messages2.allMessagesFetched, true);
    expect(user1Messages2.messages, [expectedMessage]);

    final user2Messages2 = await messageQueue2.next;
    expect(user2Messages2.allMessagesFetched, true);
    expect(user2Messages2.messages, [expectedMessage]);
  });

  test("Error on on sending a message to self", () {
    expect(
      () async => await user1.chat.sendMessage(
        chatId: chatId,
        receiverId: user1.id,
        content: user1.id,
      ),
      throwsA(TypeMatcher<MessageConnectionError>()),
    );
  });

  test(
      "sending 5 messages then login again "
      "and listening to them while fetching them slowly "
      "and then sending another one on the same chat", () async {
    final messageNotificationQueue =
        StreamQueue(user2.chat.messagesNotificationStream);

    var expectedMessages = [];
    for (var i = 0; i < 5; i++) {
      final messageContent = faker.lorem.sentence();

      user1.chat.sendMessage(
        chatId: chatId,
        receiverId: user2.id,
        content: messageContent,
      );

      expectedMessages.add(
        MessageMatcher(
          chatId: chatId,
          content: messageContent,
          senderId: user1.id,
          receiverId: user2.id,
        ),
      );

      await Future.delayed(Duration(seconds: 1));
    }

    expectedMessages = expectedMessages.reversed.toList();

    final actualMessages =
        (await messageNotificationQueue.lookAhead(5)).reversed.toList();
    expect(actualMessages, expectedMessages);

    final newUser1 = await user1.copyAndRefresh();
    newUser1.chat.listenToSpecificChat(chatId, startMaxMessageCount: 2);
    final messageQueue = StreamQueue(newUser1.chat.messagesFromSpecificChat!);

    // slowly load all of the messages
    final messages1 = await messageQueue.next;
    expect(messages1.allMessagesFetched, false);
    expect(messages1.messages, actualMessages.sublist(0, 2));

    newUser1.chat.fetchMoreMessages(howMany: 2);
    final messages2 = await messageQueue.next;
    expect(messages2.allMessagesFetched, false);
    expect(messages2.messages, actualMessages.sublist(0, 4));

    newUser1.chat.fetchMoreMessages(howMany: 100);
    final messages3 = await messageQueue.next;
    expect(messages3.allMessagesFetched, true);
    expect(messages3.messages, actualMessages);

    // Send another message and expect it to also show up
    final longMessageContent =
        faker.lorem.sentences(10).reduce((value, element) => value + element);
    user2.chat.sendMessage(
      chatId: chatId,
      receiverId: user1.id,
      content: longMessageContent,
    );
    final messages4 = await messageQueue.next;
    expect(messages4.allMessagesFetched, true);
    expect(
      messages4.messages,
      [
        MessageMatcher(
          chatId: chatId,
          content: longMessageContent,
          senderId: user2.id,
          receiverId: user1.id,
        ),
        ...expectedMessages,
      ],
    );

    await newUser1.close();
  });

  tearDown(() async {
    await user1.close();
    await user2.close();
  });
}
