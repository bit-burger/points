import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:points/pages/auth/auth_initial_page.dart';
import 'package:points/pages/auth/auth_page.dart';
import 'package:points/pages/auth/connection_error_page.dart';
import 'package:points/pages/home/home_navigator.dart';
import 'package:points/state_management/auth/auth_cubit.dart';
import 'package:points/state_management/profile/profile_cubit.dart';
import 'package:points/state_management/relations/relations_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_repositories/profile_repository.dart';
import 'package:user_repositories/relations_repository.dart';
import 'package:user_repositories/user_discovery_repository.dart';

class AuthNavigator extends StatelessWidget {
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
                key: ValueKey("ConnectionErrorPage"),
                child: WillPopScope(
                  onWillPop: () async => false,
                  child: ConnectionErrorPage(),
                ),
              ),
            if (state is LoggedInState)
              MaterialPage(
                key: ValueKey("HomePageNavigator"),
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
                  ],
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) => RelationsCubit(
                          authCubit: context.read<AuthCubit>(),
                          relationsRepository:
                              context.read<RelationsRepository>(),
                        )..startListening(),
                      ),
                      BlocProvider(
                        create: (context) => ProfileCubit(
                          profileRepository: context.read<ProfileRepository>(),
                          connectionCubit: context.read<AuthCubit>(),
                        )..startListening(),
                      ),
                    ],
                    child: HomeNavigator(),
                  ),
                ),
              ),
          ],
          onPopPage: (route, result) {
            return route.didPop(result);
          },
        );
      },
    );
  }
}
