import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:ionicons/ionicons.dart';
import 'package:points/state_management/friend/friend_cubit.dart';
import 'package:points/state_management/relations/relations_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/points_colors.dart' as pointsColors;
import '../../theme/points_icons.dart' as pointsIcons;
import '../../widgets/neumorphic_icon_button.dart';

class FriendPage extends StatelessWidget {
  /// TODO: Add buttons "give points" and "unfriend"
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FriendCubit, FriendState>(
      listener: (context, state) {
        if(state is FriendUnfriendedState) {
          Navigator.of(context).pop();
        }
      },
      buildWhen: (oldState, newState) => newState is! FriendUnfriendedState,
      builder: (context, state) {
        final friend = (state as FriendDataState).data;
        final color = pointsColors.colors[friend.color];
        return Neumorphic(
          child: Padding(
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
                  children: [
                    Expanded(
                      child: NeumorphicIconButton(
                        icon: Icon(Ionicons.chatbox_outline),
                        text: Text("Chat"),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            "/chat/${friend.chatId}/${friend.id}",
                          );
                        },
                        style: NeumorphicStyle(
                          color: color,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: NeumorphicIconButton(
                        icon: Icon(Ionicons.close_circle_outline),
                        text: Text("Block"),
                        onPressed: () {
                          context.read<RelationsCubit>().block(friend.id);
                        },
                        style: NeumorphicStyle(
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    height: 32 + MediaQuery.of(context).viewPadding.bottom),
              ],
            ),
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
