import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import 'loader.dart';

class NeumorphicLoadingTextButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool? loading;
  final Widget? loader;
  final EdgeInsets? padding;
  final NeumorphicStyle? style;

  const NeumorphicLoadingTextButton({
    required this.child,
    required this.onPressed,
    this.tooltip,
    this.loading,
    this.loader,
    this.padding,
    this.style,
  }) : super();

  @override
  Widget build(BuildContext context) {
    late final Widget child;
    if (loading != null) {
      child = AnimatedCrossFade(
        crossFadeState:
            !loading! ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        firstChild: this.child,
        secondChild: loader ?? Loader(),
        firstCurve: Curves.easeOutExpo,
        secondCurve: Curves.easeOutExpo,
        duration: Duration(milliseconds: 250),
      );
    } else {
      child = this.child;
    }
    final enabled = onPressed != null && loading != true;
    final depth = enabled ? null : -NeumorphicTheme.of(context)!.current!.depth;
    return IgnorePointer(
      ignoring: !enabled,
      child: NeumorphicButton(
        padding: padding,
        tooltip: tooltip,
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
        style: style?.copyWith(depth: depth) ??
            NeumorphicStyle(
              boxShape: NeumorphicBoxShape.stadium(),
              depth: depth,
            ),
        duration: Duration(milliseconds: 250),
        onPressed: onPressed ?? () {},
      ),
    );
  }
}
