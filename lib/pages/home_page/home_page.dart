import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:ionicons/ionicons.dart';
import 'package:points/state_management/auth_cubit.dart';
import 'package:points/state_management/profile_cubit.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'package:points_repositories/points_repositories.dart';
import '../../widgets/neumorphic_app_bar_fix.dart' as fix;
import '../../theme/points_colors.dart' as points;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        RootUser? rootUser;
        if (state is ProfileExistsState) {
          rootUser = state.profile;
        }
        return IgnorePointer(
          ignoring: state is ProfileLoadingState,
          child: NeumorphicScaffold(
            appBar: fix.NeumorphicAppBar(
              title: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: Text(
                  rootUser?.name ?? "...",
                  key: ValueKey(rootUser),
                ),
              ),
              leading: NeumorphicButton(
                tooltip: "Search for users",
                child: Icon(Ionicons.search_outline),
                onPressed: () {},
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.circle(),
                ),
              ),
              trailing: NeumorphicButton(
                tooltip: "Settings",
                child: Icon(Ionicons.settings_outline),
                onPressed: () {},
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.circle(),
                ),
              ),
            ),
            body: BlocListener<ProfileCubit, ProfileState>(
              listener: (context, state) {
                if (state is ProfileExistsState) {
                  Scaffold.of(context).showBottomSheet(
                    (context) => Container(
                      height: 50,
                      color: points.colors[state.profile.color],
                      child: Center(
                        child: Text(
                          "${state.profile.name}: ${state.profile.points}",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
              child: Center(
                child: TextButton(
                  onPressed: () {
                    context.read<AuthCubit>().logOut();
                  },
                  child: Text("Log out"),
                ),
              ),
            ),
            extendBodyBehindAppBar: true,
          ),
        );
      },
    );
  }
}
