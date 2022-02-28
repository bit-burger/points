import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide NeumorphicAppBar;
import 'package:points/state_management/profile/profile_cubit.dart';
import 'package:points/state_management/relations/relations_cubit.dart';
import 'package:points/theme/points_colors.dart';
import 'package:points/widgets/neumorphic_app_bar_fix.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'package:points/widgets/user_list_tile.dart';
import 'package:points/pages/give_points/give_friend_points_dialog.dart';

/// See all your points and gives,
/// as well as your friends with points and gives,
/// only one click needed to get to the [GiveFriendPointsDialog[
class GivePointsPage extends StatelessWidget {
  static final boldTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: textLabelColor,
  );

  Widget _buildPointsAndGives() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (oldState, newState) {
        if (oldState is ProfileExistsState && newState is ProfileExistsState) {
          return oldState.profile.points != newState.profile.points ||
              oldState.profile.gives != newState.profile.gives;
        }
        return true;
      },
      builder: (context, state) {
        final profile = (state as ProfileExistsState).profile;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 52),
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 250),
              child: Row(
                key: UniqueKey(),
                mainAxisSize: MainAxisSize.min,
                textBaseline: TextBaseline.alphabetic,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  Text(
                    profile.points.toString(),
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 4),
                  Text(
                    "points",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  SizedBox(width: 24),
                  Text(
                    profile.gives.toString(),
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 4),
                  Text(
                    "gives",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTooLittleGivesError() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final profile = (state as ProfileExistsState).profile;
        final enoughGives = profile.gives > 0;
        return enoughGives
            ? SizedBox()
            : Column(
                children: [
                  SizedBox(height: 48),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      "Not enough gives, "
                      "you can't give any of your friends points!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textLabelColor),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              );
      },
    );
  }

  Widget _buildColumnTitles() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text("name", style: boldTextStyle),
            ),
          ),
          Expanded(
            child: Center(
              child: Text("gives", style: boldTextStyle),
            ),
          ),
          Expanded(
            child: Center(
              child: Text("points", style: boldTextStyle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList(BuildContext context) {
    return Expanded(
      child: Neumorphic(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: BlocBuilder<ProfileCubit, ProfileState>(
          // Only build if the gives have changed from there being none, to there some gives
          buildWhen: (oldState, newState) {
            if (oldState is ProfileExistsState &&
                newState is ProfileExistsState) {
              return (oldState.profile.gives == 0) !=
                  (newState.profile.points == 0);
            }
            return true;
          },
          builder: (context, state) {
            final profile = (state as ProfileExistsState).profile;
            return BlocBuilder<RelationsCubit, RelationsState>(
              buildWhen: (oldState, newState) => newState is RelationsData,
              builder: (context, state) {
                final friends = (state as RelationsData).userRelations.friends;
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  child: friends.isEmpty
                      ? Center(
                          child: Text(
                            "No friends :(",
                            style: Theme.of(context)
                                .textTheme
                                .headline5!
                                .copyWith(color: Theme.of(context).hintColor),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          key: UniqueKey(),
                          itemCount: friends.length,
                          itemBuilder: (context, index) {
                            final friend = friends[index];
                            return UserListTile(
                              color: friend.color,
                              icon: friend.icon,
                              name: friend.name,
                              gives: friend.gives,
                              points: friend.points,
                              margin: EdgeInsets.symmetric(vertical: 12),
                              onPressed: profile.gives == 0
                                  ? null
                                  : () {
                                      Navigator.of(context).pushNamed(
                                        "/give-friend-points/${friend.id}",
                                      );
                                    },
                            );
                          },
                        ),
                );
              },
            );
          },
        ),
        style: NeumorphicStyle(
          depth: -NeumorphicTheme.depth(context)!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicScaffold(
      appBar: NeumorphicAppBar(
        title: Text("Give points"),
        leading: NeumorphicBackButton(
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.circle(),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            _buildPointsAndGives(),
            _buildTooLittleGivesError(),
            SizedBox(height: 32),
            _buildColumnTitles(),
            SizedBox(height: 8),
            _buildFriendsList(context),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
