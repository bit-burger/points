import 'package:chat_repository/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notification_repository/notification_repository.dart';
import 'package:points/pages/auth/auth_initial_page.dart';
import 'package:points/pages/auth/auth_page.dart';
import 'package:points/pages/auth/connection_lost_page.dart';
import 'package:points/pages/home/home_navigator.dart';
import 'package:points/state_management/auth/auth_cubit.dart';
import 'package:points/state_management/notifications/notification_cubit.dart';
import 'package:points/state_management/notifications/notification_unread_count_cubit.dart';
import 'package:points/state_management/profile/profile_cubit.dart';
import 'package:points/state_management/relations/relations_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_repositories/profile_repository.dart';
import 'package:user_repositories/relations_repository.dart';
import 'package:user_repositories/user_discovery_repository.dart';

/// Listens to the [AuthCubit] to show the correct page.
///
/// Waiting for auto log in to complete: [AuthInitialPage]
/// Not logged in: [AuthPage]
/// Connection error: [ConnectionLostPage]
/// Logged in: [HomeNavigator] along with the all the repositories,
///            that need a logged in [SupabaseClient] and the shared Cubits
class AuthNavigator extends StatelessWidget {
  Page _buildHome() {
    return MaterialPage(
      key: ValueKey("HomePageNavigator"),
      child: WillPopScope(
        onWillPop: () async => false,
        child: MultiRepositoryProvider(
          providers: [
            RepositoryProvider(
              create: (_) => ProfileRepository(
                client: Supabase.instance.client,
              ),
            ),
            RepositoryProvider(
              create: (_) => RelationsRepository(
                client: Supabase.instance.client,
              ),
            ),
            RepositoryProvider(
              create: (_) => UserDiscoveryRepository(
                client: Supabase.instance.client,
              ),
            ),
            RepositoryProvider(
              create: (_) => ChatRepository(
                client: Supabase.instance.client,
              ),
            ),
            RepositoryProvider(
              create: (_) => NotificationRepository(
                client: Supabase.instance.client,
              ),
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => RelationsCubit(
                  authCubit: context.read<AuthCubit>(),
                  relationsRepository: context.read<RelationsRepository>(),
                )..startListening(),
              ),
              BlocProvider(
                create: (context) => ProfileCubit(
                  profileRepository: context.read<ProfileRepository>(),
                  connectionCubit: context.read<AuthCubit>(),
                )..startListening(),
              ),
              BlocProvider(
                create: (context) => NotificationCubit(
                  relationsRepository: context.read<RelationsRepository>(),
                  chatRepository: context.read<ChatRepository>(),
                  authCubit: context.read<AuthCubit>(),
                  notificationRepository:
                      context.read<NotificationRepository>(),
                  userDiscoveryRepository:
                      context.read<UserDiscoveryRepository>(),
                  profileRepository: context.read<ProfileRepository>(),
                )..startListening(),
              ),
              BlocProvider(
                create: (context) => NotificationUnreadCountCubit(
                  notificationRepository:
                      context.read<NotificationRepository>(),
                  authCubit: context.read<AuthCubit>(),
                )..startListening(),
              ),
            ],
            child: HomeNavigator(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (_, state) {
        return Navigator(
          pages: [
            MaterialPage(
              name: "Loading...",
              child: AuthInitialPage(),
              maintainState: false,
            ),
            if (state is! AuthInitialState)
              MaterialPage(
                name: "Log in",
                child: WillPopScope(
                  onWillPop: () async => false,
                  child: AuthPage(),
                ),
              ),
            if (state is LoggedInPausedOnConnectionError)
              MaterialPage(
                name: "Connection failed",
                key: ValueKey("ConnectionLostPage"),
                child: WillPopScope(
                  onWillPop: () async => false,
                  child: ConnectionLostPage(),
                ),
              ),
            if (state is LoggedInState) _buildHome(),
          ],
          onPopPage: (route, result) {
            return route.didPop(result);
          },
        );
      },
    );
  }
}
