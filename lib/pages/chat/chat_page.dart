import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:ionicons/ionicons.dart';
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

/// Using the [ChatCubit] chat with friends, paging included.
///
/// Can be opened for the preferred friend from [HomeNavigator]
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
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  bool _loadingMore = false;

  void _scrollChanged() {
    final allMessagesFetched =
        (context.read<ChatCubit>().state as MessagesData).allMessagesFetched;
    if (!allMessagesFetched &&
        !_loadingMore &&
        128 >
            _scrollController.position.maxScrollExtent -
                _scrollController.position.pixels) {
      _loadingMore = true;
      context.read<ChatCubit>().fetchMoreMessages();
    }
  }

  Widget _buildChat(MessagesData messagesData) {
    final chatCubit = context.read<ChatCubit>();

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

    return Stack(
      children: [
        SingleChildScrollView(
          reverse: true,
          padding: EdgeInsets.zero,
          controller: _scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SafeArea(
                bottom: false,
                child: SizedBox(
                  height: 64,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: messagesData.allMessagesFetched
                        ? Text(
                            "No other messages",
                            style: TextStyle(
                              color: Theme.of(context).disabledColor,
                            ),
                          )
                        : Loader(),
                  ),
                ),
              ),
              SafeArea(
                minimum: EdgeInsets.only(bottom: 16),
                top: false,
                child: MessageListView(
                  scrollController: ScrollController(),
                  // TODO: Parsing of things like **bold**, *italic*
                  parsePatterns: [],
                  messageContainerPadding: EdgeInsets.zero,
                  dateFormat: DateFormat("dd MMM y"),
                  messages: messages.toList(),
                  onLoadEarlier: chatCubit.fetchMoreMessages,
                  showLoadMore: false,
                  showAvatarForEverMessage: false,
                  showuserAvatar: false,
                  user: self,
                  inverted: true,
                  visible: true,
                  changeVisible: (_) {},
                  messageDecorationBuilder: (message, isUser) => BoxDecoration(
                    color: message.user.containerColor,
                    borderRadius: BorderRadius.circular(8.0),
                    border: message.user.containerColor == pointColors.white
                        ? Border.all(color: Colors.black, width: 0.5)
                        : null,
                  ),
                  messageTextBuilder: (message, [ChatMessage? __]) =>
                      Text(message!),
                  messageTimeBuilder: (_, [ChatMessage? __]) => SizedBox(),
                  avatarBuilder: (user) {
                    return CircleAvatar(
                      backgroundColor: user.containerColor == pointColors.white
                          ? Colors.black
                          : Colors.transparent,
                      radius: 17.5,
                      child: CircleAvatar(
                        child: Icon(user.customProperties!["icon"], size: 18),
                        radius: 17,
                        foregroundColor: Colors.black,
                        backgroundColor: user.color,
                      ),
                    );
                  },
                  defaultLoadCallback: (bool) => true,
                ),
              ),
              SizedBox(
                height: 72,
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          minimum: EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              Spacer(),
              Neumorphic(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: ValueListenableBuilder<TextEditingValue>(
                  builder: (context, text, child) {
                    return ChatInputToolbar(
                      scrollController: _scrollController,
                      focusNode: _chatNode,
                      onTextChange: (_) {},
                      inputMaxLines: 16,
                      sendButtonBuilder: (fn) {
                        final disabled = text.text.isEmpty;
                        return CupertinoButton(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Icon(
                            Ionicons.send_outline,
                            color: disabled ? Colors.black45 : Colors.black,
                          ),
                          onPressed: disabled ? null : () => fn.call(),
                        );
                      },
                      alwaysShowSend: true,
                      controller: _textController,
                      user: self,
                      sendOnEnter: true,
                      textInputAction: TextInputAction.send,
                      textCapitalization: TextCapitalization.sentences,
                      text: text.text,
                      onSend: (message) {
                        chatCubit.sendMessage(message.text!);
                      },
                      inputDisabled: false,
                      inputContainerStyle: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      inputDecoration: InputDecoration(
                        hintText: "message...",
                        border: InputBorder.none,
                      ),
                    );
                  },
                  valueListenable: _textController,
                ),
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.roundRect(
                      BorderRadius.circular(56 / 2)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Loader(),
    );
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
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          _loadingMore = false;
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
            child: state is MessagesData ? _buildChat(state) : _buildLoader(),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    _chatNode.requestFocus();
    _scrollController.addListener(_scrollChanged);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollChanged);
    super.dispose();
  }
}
