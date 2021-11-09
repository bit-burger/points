import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:ionicons/ionicons.dart';
import 'package:points/state_management/auth_cubit.dart';
import 'package:points/state_management/profile_cubit.dart';
import 'package:points/widgets/loader.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'package:user_repositories/profile_repository.dart';
import '../../widgets/neumorphic_app_bar_fix.dart' as fix;
import '../../theme/points_colors.dart' as points;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        bool isLoading = state is ProfileLoadingState;
        User? rootUser;
        if (state is ProfileExistsState) {
          rootUser = state.profile;
        }
        return IgnorePointer(
          ignoring: isLoading,
          child: NeumorphicScaffold(
            extendBodyBehindAppBar: true,
            appBar: fix.NeumorphicAppBar(
              title: AnimatedSwitcher(
                duration: Duration(milliseconds: 250),
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
            floatingActionButton: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: kToolbarHeight,
                maxHeight: kToolbarHeight,
                minWidth: kToolbarHeight,
              ),
              child: NeumorphicButton(
                onPressed: () {
                  final name = rootUser!.name;
                  final newName = name.length == 8
                      ? name.substring(0, name.length - 1)
                      : name + "a";

                  context
                      .read<ProfileCubit>()
                      .updateProfile(newName, null, null, null, null);
                },
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: isLoading
                      ? Loader()
                      : Text(
                          rootUser?.points.toString() ?? "",
                          style:
                              Theme.of(context).textTheme.headline4!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                ),
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.stadium(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
