import 'package:flutter_neumorphic/flutter_neumorphic.dart';

/// A round NeumorphicButton with a Icon
class NeumorphicIconButton extends StatelessWidget {
  final Widget icon;
  final Widget text;
  final VoidCallback onPressed;
  final NeumorphicStyle? style;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const NeumorphicIconButton({
    required this.icon,
    required this.text,
    required this.onPressed,
    this.style,
    this.padding,
    this.margin,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      padding: padding,
      margin: margin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          SizedBox(width: 8),
          DefaultTextStyle(
            child: text,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  fontSize: 18,
                ),
          ),
        ],
      ),
      onPressed: onPressed,
      style: (style ?? NeumorphicStyle()).copyWith(
        boxShape: NeumorphicBoxShape.stadium(),
      ),
    );
  }
}
