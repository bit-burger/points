import 'package:chat_repository/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:notification_repository/notification_repository.dart';
import 'package:points/pages/chat/chat_page.dart';
import 'package:points/pages/give_points/give_friend_points_dialog.dart';
import 'package:points/pages/give_points/give_points_page.dart';
import 'package:points/pages/notifications/notification_delegate.dart';
import 'package:points/pages/notifications/notifications_page.dart';
import 'package:points/pages/profile/profile_page.dart';
import 'package:points/pages/friend/friend_page.dart';
import 'package:points/pages/user_discovery/user_discovery_page.dart';
import 'package:points/state_management/auth/auth_cubit.dart';
import 'package:points/state_management/chat/chat_cubit.dart';
import 'package:points/state_management/friend/friend_cubit.dart';
import 'package:points/state_management/give_friend_points/give_friend_points_cubit.dart';
import 'package:points/state_management/notifications/notification_paging_cubit.dart';
import 'package:points/state_management/user_discovery/user_discovery_cubit.dart';
import 'package:points/theme/points_colors.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'package:user_repositories/profile_repository.dart';
import 'package:user_repositories/relations_repository.dart';
import 'package:user_repositories/user_discovery_repository.dart';

import 'home_page.dart';
import 'info_dialog.dart';

/// Contains all routes needed,
/// for the part of the application where the user is logged in.
///
/// Also inserts the NotificationDelegate into the widget tree
/// for in app notifications
class HomeNavigator extends StatefulWidget {
  @override
  State<HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {
  GlobalKey<NavigatorState> _navState = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return NotificationDelegate(
      chatOpenCallback: (String chatId, String userId) {
        _navState.currentState!.pushNamed("/chat/$chatId/$userId");
      },
      notificationsOpenCallback: () {
        _navState.currentState!.pushNamed("/notifications");
      },
      child: Navigator(
        key: _navState,
        initialRoute: "/home",
        onGenerateRoute: (settings) {
          final uri = Uri.parse(settings.name!).pathSegments;
          if (uri.length == 0) {
            return null;
          }
          switch (uri.first) {
            case "home":
              return MaterialPageRoute(builder: (_) => HomePage());
            case "user-discovery":
              return MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => UserDiscoveryCubit(
                    userDiscoveryRepository:
                        context.read<UserDiscoveryRepository>(),
                    authCubit: context.read<AuthCubit>(),
                    relationsRepository: context.read<RelationsRepository>(),
                  )..awaitPages(),
                  child: UserDiscoveryPage(),
                ),
              );
            case "profile":
              return MaterialPageRoute(builder: (_) => ProfilePage());
            case "notifications":
              return MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => NotificationPagingCubit(
                    profileRepository: context.read<ProfileRepository>(),
                    relationsRepository: context.read<RelationsRepository>(),
                    userDiscoveryRepository:
                        context.read<UserDiscoveryRepository>(),
                    notificationRepository:
                        context.read<NotificationRepository>(),
                    authCubit: context.read<AuthCubit>(),
                  )..startListening(),
                  child: NotificationsPage(),
                ),
              );
            case "info":
              return DialogRoute(
                barrierColor: barrierColor,
                context: context,
                builder: (_) => InfoDialog(),
              );
            case "give-friend-points":
              if (uri.length < 2) {
                return null;
              }
              final friendId = uri[1];
              return DialogRoute(
                barrierColor: barrierColor,
                context: context,
                builder: (_) => BlocProvider(
                  create: (context) => GiveFriendPointsCubit(
                    relationsRepository: context.read<RelationsRepository>(),
                    profileRepository: context.read<ProfileRepository>(),
                  )..selectFriend(friendId: friendId),
                  child: GiveFriendPointsDialog(),
                ),
              );
            case "give-points":
              return MaterialPageRoute(
                builder: (_) => GivePointsPage(),
              );
            case "friend":
              if (uri.length < 2) {
                return null;
              }
              final friendId = uri[1];
              return ModalBottomSheetRoute(
                modalBarrierColor: barrierColor,
                expanded: false,
                builder: (_) => BlocProvider(
                  create: (context) => FriendCubit(
                    context.read<RelationsRepository>(),
                  )..loadFriendData(friendId: friendId),
                  child: FriendPage(),
                ),
              );
            case "chat":
              if (uri.length < 3) {
                return null;
              }
              final chatId = uri[1];
              final userId = uri[2];
              return MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (context) => ChatCubit(
                    chatId: chatId,
                    userId: userId,
                    chatRepository: context.read<ChatRepository>(),
                    profileRepository: context.read<ProfileRepository>(),
                    relationsRepository: context.read<RelationsRepository>(),
                    authCubit: context.read<AuthCubit>(),
                  )..loadMessages(),
                  child: ChatPage(
                    chatId: chatId,
                    userId: userId,
                  ),
                ),
              );
          }
        },
        onUnknownRoute: (_) {
          return MaterialPageRoute(
            builder: (BuildContext context) {
              return NeumorphicScaffold(
                body: Center(
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                            color: Theme.of(context).errorColor,
                          ),
                      children: [
                        TextSpan(
                          text: "404: ",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: "Page not found",
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
