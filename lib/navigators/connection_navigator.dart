import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:points/pages/relationships/home_page.dart';
import 'package:points/state_management/connection_cubit.dart';
import 'package:points/state_management/profile_cubit.dart';
import 'package:points/state_management/relationships_cubit.dart';

class ConnectionNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionCubit, ConnectionState>(
      builder: (_, state) {
        return Navigator(
          pages: [
            MaterialPage(
              name: "Homepage",
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => RelationshipsCubit()),
                  BlocProvider(create: (_) => ProfileCubit()),
                ],
                child: HomePage(),
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
