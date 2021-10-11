import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import 'loader.dart';

class NeumorphicLoadingTextButton extends StatelessWidget {
  final bool? loading;
  final Widget child;
  final VoidCallback? onPressed;

  const NeumorphicLoadingTextButton({
    required this.child,
    required this.onPressed,
    this.loading,
  }) : super();

  @override
  Widget build(BuildContext context) {
    late final Widget child;
    if (loading != null) {
      child = AnimatedCrossFade(
        crossFadeState:
            !loading! ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        firstChild: this.child,
        secondChild: Loader(),
        firstCurve: Curves.easeOutExpo,
        secondCurve: Curves.easeOutExpo,
        duration: Duration(milliseconds: 250),
      );
    } else {
      child = this.child;
    }
    final enabled = onPressed != null && loading != true;
    return IgnorePointer(
      ignoring: !enabled,
      child: NeumorphicButton(
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 250),
            style: Theme.of(context).textTheme.headline6!.copyWith(
                  color: enabled ? null : Theme.of(context).disabledColor,
                  fontWeight: FontWeight.w600,
                ),
            child: child,
          ),
        ),
        style: NeumorphicStyle(
          boxShape: NeumorphicBoxShape.stadium(),
          depth: enabled ? null : -NeumorphicTheme.of(context)!.current!.depth,
        ),
        duration: Duration(milliseconds: 250),
        onPressed: onPressed ?? () {},
      ),
    );
  }
}
