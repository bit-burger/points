import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:ionicons/ionicons.dart';
import '../theme/points_colors.dart' show colors;

class UserListTile extends StatelessWidget {
  final String name;
  final String status;
  final int color;
  final int points;
  final int icon;

  final VoidCallback onPressed;
  // TODO: Implement onLongPressed
  final VoidCallback? onLongPressed;

  const UserListTile({
    required this.name,
    required this.status,
    required this.color,
    required this.points,
    required this.icon,
    required this.onPressed,
    this.onLongPressed,
  }) : super();

  // TODO: Better scaling
  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(Ionicons.copy_outline),
          SizedBox(width: 16),
          Text(name.padRight(8)),
          SizedBox(width: 16),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          SizedBox(width: 12),
          Spacer(),
          // TODO: Better text scaling
          Text(
            points.toString(),
            textScaleFactor: 1.5,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
        ],
      ),
      onPressed: () {},
      style: NeumorphicStyle(
        color: colors[color],
        boxShape: NeumorphicBoxShape.stadium(),
      ),
    );
  }
}
