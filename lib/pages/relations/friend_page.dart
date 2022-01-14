import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:ionicons/ionicons.dart';
import 'package:points/state_management/relations/relations_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/points_colors.dart' as pointsColors;
import '../../theme/points_icons.dart' as pointsIcons;
import '../../widgets/neumorphic_icon_button.dart';

class FriendPage extends StatelessWidget {
  final String friendId;
  FriendPage({required this.friendId}) : super();

  /// TODO: Add buttons "give points" and "unfriend"
  @override
  Widget build(BuildContext context) {
    final friend = (context.read<RelationsCubit>().state as RelationsData)
        .userRelations
        .friends
        .firstWhere((friend) => friend.id == friendId);
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
                Text(friend.name, style: Theme.of(context).textTheme.headline4)
              ],
            ),
            SizedBox(height: 32),
            Text(friend.status, style: Theme.of(context).textTheme.headline6),
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
                      Navigator.pop(context);
                    },
                    style: NeumorphicStyle(
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32 + MediaQuery.of(context).viewPadding.bottom),
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
  }
}

// showModalBottomSheet(
// shape: RoundedRectangleBorder(
// borderRadius: BorderRadius.circular(50),
// ),
// context: context,
// isScrollControlled: true,
// barrierColor: colors.barrierColor,
// builder: (context) => _buildFriendDetailView(context, user),
// );