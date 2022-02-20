import 'package:flutter_neumorphic/flutter_neumorphic.dart';

/// A smaller button that looks similar to a [Chip], but in neumorphic design
class NeumorphicChipButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const NeumorphicChipButton({
    required this.child,
    required this.onPressed,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      onPressed: onPressed,
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.stadium(),
      ),
      child: AnimatedDefaultTextStyle(
        style: Theme.of(context).textTheme.bodyText2!.copyWith(
              fontWeight: FontWeight.w500,
              color: onPressed == null ? Theme.of(context).disabledColor : null,
            ),
        duration: Duration(milliseconds: 250),
        child: child,
      ),
    );
  }
}
