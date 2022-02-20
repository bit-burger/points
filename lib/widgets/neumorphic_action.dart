import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:ionicons/ionicons.dart';
import 'package:badges/badges.dart';
import '../theme/points_colors.dart' as pointsColors;

/// A round styled neumorphic button,
/// that never completely touches the ground,
/// as it is used over Lists and Grid.
class NeumorphicAction extends StatelessWidget {
  final int? badgeNotifications;
  final String? tooltip;
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsets? margin;

  const NeumorphicAction({
    this.badgeNotifications,
    this.tooltip,
    this.margin,
    this.onPressed,
    required this.child,
  }) : assert((badgeNotifications ?? 0) >= 0);

  static Widget backButton() {
    return _BackButton();
  }

  @override
  Widget build(BuildContext context) {
    final widget = NeumorphicButton(
      padding: EdgeInsets.zero,
      tooltip: tooltip,
      child: SizedBox.fromSize(
        size: Size.square(56),
        child: child,
      ),
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.circle(),
        depth: 8,
        intensity: 0.7,
      ),
      minDistance: 3,
      onPressed: onPressed,
    );
    if (badgeNotifications == null || badgeNotifications == 0) {
      return widget;
    }
    return Badge(
      position: BadgePosition(
        end: -6,
        top: -6,
      ),
      badgeColor: pointsColors.white,
      badgeContent: Text(badgeNotifications!.toString()),
      shape: badgeNotifications! >= 10 ? BadgeShape.square : BadgeShape.circle,
      padding: EdgeInsets.all(3),
      borderRadius: BorderRadius.circular(50),
      child: widget,
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NeumorphicAction(
      tooltip: "Back",
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Icon(Ionicons.arrow_back),
    );
  }
}
