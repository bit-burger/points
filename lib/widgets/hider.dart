import 'package:flutter/material.dart';

class Hider extends StatelessWidget {
  final Widget child;
  final bool hide;

  const Hider({
    required this.child,
    required this.hide,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: child,
      secondChild: SizedBox(),
      crossFadeState:
          !hide ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: Duration(milliseconds: 250),
    );
  }
}
