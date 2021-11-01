import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:points/pages/home_page/create_profile_page.dart';
import 'package:points/pages/home_page/home_page.dart';
import 'package:points/state_management/profile_cubit.dart';

class HomePageNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(builder: (context, state) {
      return Navigator(
        pages: [
          if (state is NoProfileExistsState || state is ProfileLoadingState)
            MaterialPage(
              name: "Create your account",
              key: ValueKey("CreateProfilePage"),
              child: CreateProfilePage(),
            ),
          if (state is ProfileExistsState || state is ProfileInitialState)
            MaterialPage(
              name: "Homepage",
              key: ValueKey("HomePage"),
              child: HomePage(),
            ),
        ],
        onPopPage: (route, result) {
          return route.didPop(result);
        },
      );
    });
  }
}
