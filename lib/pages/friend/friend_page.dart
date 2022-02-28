import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:ionicons/ionicons.dart';
import 'package:points/state_management/friend/friend_cubit.dart';
import 'package:points/state_management/profile/profile_cubit.dart';
import 'package:points/state_management/relations/relations_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:points/widgets/points_logo.dart';
import '../../theme/points_colors.dart' as pointsColors;
import '../../theme/points_icons.dart' as pointsIcons;
import '../../widgets/neumorphic_icon_button.dart';
import '../home/home_navigator.dart';

/// View a Friend in detail,
/// start a chat, give them points, unfriend, or unblock them
///
/// Only uses the [FriendCubit].
///
/// Can be opened for the preferred friend from [HomeNavigator]
class FriendPage extends StatelessWidget {
  // TODO: Check alternative designs for (now hidden) unfriend and block buttons
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FriendCubit, FriendState>(
      listener: (context, state) {
        if (state is FriendUnfriendedState) {
          Navigator.of(context).pop();
        }
      },
      buildWhen: (oldState, newState) => newState is! FriendUnfriendedState,
      builder: (context, state) {
        final friend = (state as FriendDataState).data;
        final color = pointsColors.colors[friend.color];
        return Neumorphic(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          pointsIcons.pointsIcons[friend.icon],
                          size: 48,
                        ),
                        SizedBox(width: 16),
                        Text(friend.name,
                            style: Theme.of(context).textTheme.headline4)
                      ],
                    ),
                    SizedBox(height: 32),
                    Text(friend.status,
                        style: Theme.of(context).textTheme.headline6),
                    SizedBox(height: 32),
                    Text(
                      friend.bio,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 48),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      textBaseline: TextBaseline.alphabetic,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      children: [
                        Text(
                          friend.points.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 4),
                        Text("points"),
                        SizedBox(width: 16),
                        Text(
                          friend.gives.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 4),
                        Text("gives"),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                height: 82,
                child: Container(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.only(left: 16),
                    children: [
                      SizedBox.shrink(
                        child: NeumorphicIconButton(
                          icon: Icon(Ionicons.chatbox_outline),
                          text: Text("Chat"),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              "/chat/${friend.chatId}/${friend.id}",
                            );
                          },
                          margin: EdgeInsets.symmetric(vertical: 16),
                          style: NeumorphicStyle(
                            color: color,
                          ),
                        ),
                      ),
                      NeumorphicIconButton(
                        icon: PointsLogo(size: 26),
                        text: Text("Give"),
                        onPressed: () {
                          final profile = (context.read<ProfileCubit>().state
                                  as ProfileExistsState)
                              .profile;
                          if (profile.gives == 0) {
                            showOkAlertDialog(
                              context: context,
                              title: "No gives",
                              message: "You don't have any gives currently, "
                                  "which means that you can't "
                                  "give anyone any points",
                            );
                          } else {
                            Navigator.of(context)
                                .pushNamed("/give-friend-points/${friend.id}");
                          }
                        },
                        margin: EdgeInsets.symmetric(vertical: 16),
                        style: NeumorphicStyle(
                          color: color,
                        ),
                      ),
                      NeumorphicIconButton(
                        icon: Icon(Ionicons.remove_circle_outline),
                        text: Text("Unfriend"),
                        onPressed: () async {
                          final result = await showOkCancelAlertDialog(
                            title: "Warning",
                            message:
                                "Do you want to unfriend '${friend.name}'?",
                            context: context,
                            isDestructiveAction: true,
                          );
                          if (result == OkCancelResult.ok) {
                            context.read<RelationsCubit>().unfriend(friend.id);
                          }
                        },
                        margin: EdgeInsets.symmetric(vertical: 16),
                        style: NeumorphicStyle(
                          color: color,
                        ),
                      ),
                      NeumorphicIconButton(
                        icon: Icon(Ionicons.close_circle_outline),
                        text: Text("Block"),
                        onPressed: () async {
                          final result = await showOkCancelAlertDialog(
                            title: "Warning",
                            message: "Do you want to block '${friend.name}'?",
                            context: context,
                            isDestructiveAction: true,
                          );
                          if (result == OkCancelResult.ok) {
                            context.read<RelationsCubit>().unblock(friend.id);
                          }
                        },
                        margin: EdgeInsets.symmetric(vertical: 16),
                        style: NeumorphicStyle(
                          color: color,
                        ),
                      ),
                    ].map<Widget>(
                      (w) {
                        return SizedBox(
                          width: (MediaQuery.of(context).size.width - 16) / 2,
                          child: Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: w,
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ),
              SizedBox(height: 32 + MediaQuery.of(context).viewPadding.bottom),
            ],
          ),
          style: NeumorphicStyle(
            intensity: 1,
            depth: NeumorphicTheme.depth(context)! * 2,
            color: color,
            boxShape: NeumorphicBoxShape.roundRect(
              BorderRadius.vertical(top: Radius.circular(32)),
            ),
          ),
        );
      },
    );
  }
}
