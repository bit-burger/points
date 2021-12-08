import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class NeumorphicBox extends StatelessWidget {
  final Widget child;
  final bool reverseHeight;
  final bool listPadding;
  final Color? color;

  const NeumorphicBox({
    required this.child,
    this.reverseHeight = false,
    this.listPadding = false,
    this.color,
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
          ? null
          : NeumorphicStyle(
              depth: -NeumorphicTheme.depth(context)!,
              color: color,
            ),
    );
  }
}
