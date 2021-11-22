import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:points/pages/auth/auth_initial_page.dart';
import 'package:points/pages/auth/auth_page.dart';
import 'package:points/pages/connection/connection_navigator.dart';
import 'package:points/state_management/auth/auth_cubit.dart';
import 'package:points/state_management/connection/connection_cubit.dart';

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
            if (state is LoggedInState)
              MaterialPage(
                child: WillPopScope(
                  onWillPop: () async => false,
                  child: BlocProvider(
                    create: (_) => ConnectionCubit(),
                    child: ConnectionNavigator(),
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
