import 'package:chat_repository/chat_repository.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:points/state_management/auth/auth_cubit.dart';
import 'package:points/state_management/chat/chat_cubit.dart';
import 'package:points/widgets/loader.dart';
import 'package:points/widgets/neumorphic_app_bar_fix.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide NeumorphicAppBar;
import 'package:user_repositories/profile_repository.dart';
import 'package:points/theme/points_colors.dart' as pointColors;
import 'package:points/theme/points_icons.dart' as pointIcons;
import 'package:user_repositories/relations_repository.dart';

extension on User {
  ChatUser toChatUser() {
    return ChatUser(
      uid: id,
      name: name,
      customProperties: {
        "icon": pointIcons.pointsIcons[icon],
      },
      color: pointColors.colors[color],
      containerColor: pointColors.colors[color],
    );
  }
}

class ChatPage extends StatefulWidget {
  final String chatId;
  final String userId;

  ChatPage({
    required this.chatId,
    required this.userId,
  }) : super();

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _chatNode = FocusNode();

  Widget _buildChat(ChatCubit chatCubit, MessagesData messagesData) {
    final self = messagesData.self.toChatUser();
    final other = messagesData.other.toChatUser();

    final messages = messagesData.messages.map((message) {
      final isSelf = message.senderId == messagesData.self.id;

      return ChatMessage(
        createdAt: message.timestamp,
        user: isSelf ? self : other,
        text: message.content,
      );
    });

    return DashChat(
      sendButtonBuilder: (fn) {
        return CupertinoButton(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Icon(Ionicons.send_outline, color: Colors.black),
          onPressed: () => fn(),
        );
      },
      user: self,
      messages: messages.toList(),
      onSend: (message) {
        chatCubit.sendMessage(message.text!);
      },
      scrollToBottom: false,
      sendOnEnter: true,
      inverted: true,
      onLoadEarlier: chatCubit.fetchMoreMessages,
      dateFormat: DateFormat("hh:mm d-M-y"),
      // shouldShowLoadEarlier: !messagesData.allMessagesFetched,
      inputDecoration: InputDecoration(
        hintText: "message...",
        border: InputBorder.none,
      ),
      chatFooterBuilder: () => Neumorphic(),
      inputContainerStyle: BoxDecoration(
        color: NeumorphicTheme.baseColor(context),
      ),
      height: double.infinity,
      focusNode: _chatNode,
      messageTimeBuilder: (_, [ChatMessage? __]) => SizedBox(),
      messageTextBuilder: (message, [ChatMessage? __]) => Text(message!),
      avatarBuilder: (user) {
        return CircleAvatar(
          child: Icon(user.customProperties!["icon"], size: 18),
          radius: 17,
          foregroundColor: Colors.black,
          backgroundColor: user.color,
        );
      },
    );
  }

  Widget _buildLoader() {
    return Center(child: Loader());
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicScaffold(
      appBar: NeumorphicAppBar(
        leading: NeumorphicBackButton(
          style: NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
        ),
        title: SizedBox(),
      ),
      extendBodyBehindAppBar: true,
      body: BlocProvider(
        create: (context) => ChatCubit(
          chatId: widget.chatId,
          userId: widget.userId,
          chatRepository: context.read<ChatRepository>(),
          profileRepository: context.read<ProfileRepository>(),
          relationsRepository: context.read<RelationsRepository>(),
          authCubit: context.read<AuthCubit>(),
        )..loadMessages(),
        child: Builder(
          builder: (context) {
            final chatCubit = context.read<ChatCubit>();
            return BlocConsumer<ChatCubit, ChatState>(
              bloc: chatCubit,
              listener: (context, state) {
                if (state is ChatClosed) {
                  Navigator.pop(context);
                }
              },
              buildWhen: (oldState, newState) {
                return newState is! ChatClosed;
              },
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: state is MessagesData
                      ? _buildChat(chatCubit, state)
                      : _buildLoader(),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    _chatNode.requestFocus();
    super.initState();
  }
}
