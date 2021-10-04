import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:points/navigators/connection_navigator.dart';
import 'package:points/pages/auth/auth_page.dart';
import 'package:points/state_management/auth_cubit.dart';
import 'package:points/state_management/connection_cubit.dart';

class AuthNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (_, state) {
        return Navigator(
          pages: [
            MaterialPage(
              child: AuthPage(),
            ),
            if (state is LoggedInState)
              MaterialPage(
                child: BlocProvider(
                  create: (_) => ConnectionCubit(),
                  child: ConnectionNavigator(),
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
