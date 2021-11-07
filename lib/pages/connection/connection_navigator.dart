import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:points/pages/connection/connection_error_page.dart';
import 'package:points/pages/home_page/home_page.dart';
import 'package:points/state_management/connection_cubit.dart';
import 'package:points/state_management/profile_cubit.dart';
import 'package:points/state_management/relationships_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_repositories/profile_repository.dart';
import 'package:user_repositories/relations_repository.dart';

class ConnectionNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionCubit, ConnectionState>(
      buildWhen: (a, b) => true,
      builder: (_, state) {
        return Navigator(
          pages: [
            if (state is ConnectionFailedState)
              MaterialPage(
                name: "Connection failed",
                key: ValueKey("ConnectionErrorPage"),
                child: ConnectionErrorPage(),
              ),
            if (state is! ConnectionFailedState)
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
                  ],
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) => RelationshipsCubit(),
                      ),
                      BlocProvider(
                        create: (context) => ProfileCubit(
                          profileRepository: context.read<ProfileRepository>(),
                          connectionCubit: context.read<ConnectionCubit>(),
                        )..startListening(),
                      ),
                    ],
                    child: BlocProvider(
                      create: (_) => ConnectionCubit(),
                      child: HomePage(),
                    ),
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
