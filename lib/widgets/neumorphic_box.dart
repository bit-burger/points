import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class NeumorphicBox extends StatelessWidget {
  final Widget child;
  final bool reverseHeight;
  final bool listPadding;
  final NeumorphicStyle? style;

  const NeumorphicBox({
    required this.child,
    this.reverseHeight = false,
    this.listPadding = false,
    this.style,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      margin: EdgeInsets.all(20),
      padding: listPadding
          ? EdgeInsets.symmetric(horizontal: 20)
          : EdgeInsets.all(20),
      child: child,
      style: !reverseHeight
          ? style
          : (style ?? NeumorphicStyle()).copyWith(
              depth: -NeumorphicTheme.depth(context)!,
            ),
    );
  }
}