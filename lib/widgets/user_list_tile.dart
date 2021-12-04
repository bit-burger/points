import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import '../theme/points_colors.dart' show colors;
import '../theme/points_icons.dart';

class UserListTile extends StatelessWidget {
  final String name;
  final String status;
  final int color;
  final int points;
  final int icon;

  final VoidCallback? onPressed;
  final VoidCallback? onLongPressed;
  final EdgeInsets? margin;
  final Key? key;

  const UserListTile({
    required this.name,
    required this.status,
    required this.color,
    required this.points,
    required this.icon,
    this.onPressed,
    this.onLongPressed,
    this.margin,
    this.key,
  }) : super(key: key);

  // TODO: Better scaling
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPressed,
      child: NeumorphicButton(
        margin: margin ?? EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(pointsIcons[icon]),
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
        style: NeumorphicStyle(
          color: colors[color],
          boxShape: NeumorphicBoxShape.stadium(),
        ),
      ),
    );
  }
}
