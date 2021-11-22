import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:ionicons/ionicons.dart';
import 'package:points/pages/relations/relations_sub_page.dart';
import 'package:points/pages/user_discovery/user_discovery_page.dart';
import 'package:points/state_management/profile/profile_cubit.dart';
import 'package:points/state_management/user_discovery/user_discovery_cubit.dart';
import 'package:points/widgets/loader.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'package:user_repositories/profile_repository.dart';
import 'package:user_repositories/relations_repository.dart';
import 'package:user_repositories/user_discovery_repository.dart';

import '../../theme/points_colors.dart' as points;
import '../../widgets/neumorphic_app_bar_fix.dart' as fix;

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
              leading: Hero(
                tag: "User search",
                transitionOnUserGestures: true,
                child: NeumorphicButton(
                  tooltip: "Search for users",
                  child: Icon(Ionicons.search_outline),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => UserDiscoveryCubit(
                            userDiscoveryRepository:
                                context.read<UserDiscoveryRepository>(),
                            relationsRepository:
                                context.read<RelationsRepository>(),
                          )..awaitPages(),
                          child: UserDiscoveryPage(),
                        ),
                      ),
                    );
                  },
                  style: NeumorphicStyle(
                    boxShape: NeumorphicBoxShape.circle(),
                  ),
                ),
              ),
              trailing: NeumorphicButton(
                tooltip: "Settings",
                child: Icon(Ionicons.settings_outline),
                onPressed: () {
                  Navigator.of(context).pushNamed("settings");
                },
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
              child: RelationsSubPage(),
            ),
            floatingActionButton: NeumorphicFloatingActionButton(
              onPressed: () {},
              style: NeumorphicStyle(
                depth: 8,
              ),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: isLoading
                    ? Loader()
                    : Text(
                        rootUser?.points.toString() ?? "",
                        style: Theme.of(context).textTheme.headline4!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
