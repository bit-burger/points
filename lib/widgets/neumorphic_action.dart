import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:ionicons/ionicons.dart';
import 'package:points/state_management/auth/auth_cubit.dart';

class NeumorphicAction extends StatelessWidget {
  final String? tooltip;
  final VoidCallback onPressed;
  final Widget child;
  final EdgeInsets? margin;

  const NeumorphicAction({
    this.tooltip,
    this.margin,
    required this.onPressed,
    required this.child,
  });

  static Widget backButton() {
    return _BackButton();
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
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
