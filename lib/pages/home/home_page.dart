import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:ionicons/ionicons.dart';
import 'package:points/pages/relations/relations_sub_page.dart';
import 'package:points/state_management/profile/profile_cubit.dart';
import 'package:points/state_management/relations/relations_cubit.dart';
import 'package:points/widgets/loader.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'package:user_repositories/profile_repository.dart';
import 'package:user_repositories/relations_repository.dart';
import 'package:user_repositories/user_discovery_repository.dart';

import '../../widgets/neumorphic_app_bar_fix.dart' as fix;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RelationsCubit, RelationsState>(
      buildWhen: (oldState, newState) {
        return oldState is RelationsInitialLoading ||
            newState is RelationsInitialLoading;
      },
      builder: (context, relationsState) {
        return BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            bool isLoading = profileState is ProfileLoadingState ||
                relationsState is RelationsInitialLoading;
            User? rootUser;
            if (profileState is ProfileExistsState) {
              rootUser = profileState.profile;
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
                        Navigator.of(context).pushNamed(
                          "/user-discovery",
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
                      Navigator.of(context).pushNamed("/profile");
                    },
                    style: NeumorphicStyle(
                      boxShape: NeumorphicBoxShape.circle(),
                    ),
                  ),
                ),
                body: RelationsSubPage(),
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
                            key: ValueKey(rootUser?.points),
                            style:
                                Theme.of(context).textTheme.headline4!.copyWith(
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
      },
    );
  }
}
