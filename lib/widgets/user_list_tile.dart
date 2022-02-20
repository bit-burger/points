import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import '../theme/points_colors.dart' show colors;
import '../theme/points_icons.dart';

/// A list tile to show the profile of a user.
///
/// Shows the color, icon, name, and points as well as the status or gives
class UserListTile extends StatelessWidget {
  final int color;
  final int icon;
  final String name;
  final String? status;
  final int? gives;
  final int points;

  final EdgeInsets? margin;
  final EdgeInsets? padding;

  final VoidCallback? onPressed;
  final VoidCallback? onLongPressed;
  final Key? key;

  const UserListTile({
    required this.color,
    required this.icon,
    required this.name,
    this.status,
    this.gives,
    required this.points,
    this.margin,
    this.padding,
    this.onPressed,
    this.onLongPressed,
    this.key,
  })  : assert((status == null) != (gives == null)),
        super(key: key);

  // TODO: Better scaling
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPressed,
      child: NeumorphicButton(
        margin: margin ?? EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(pointsIcons[icon]),
            SizedBox(width: 16),
            Text(name.padRight(8)),
            SizedBox(width: 16),
            if (status != null)
              Text(
                status!,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            if (gives != null)
              Text(
                gives!.toString(),
                textScaleFactor: 1.5,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            SizedBox(width: 12),
            if (gives != null) Spacer(flex: 2),
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
