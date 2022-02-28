import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import 'loader.dart';

/// A neumorphic themed text button,
/// with the ability to be disabled (and have a disabled text style),
/// or (with the [loading] property) to be loading
class NeumorphicLoadingTextButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool? loading;
  final Widget? loader;
  final EdgeInsets? padding, margin;
  final TextStyle? textStyle;
  final NeumorphicStyle? style;

  const NeumorphicLoadingTextButton({
    required this.child,
    required this.onPressed,
    this.tooltip,
    this.loading,
    this.loader,
    this.padding,
    this.margin,
    this.textStyle,
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
        secondChild: FittedBox(
          fit: BoxFit.scaleDown,
          child: Center(child: loader ?? Loader(compact: true)),
        ),
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
        margin: margin,
        padding: padding,
        tooltip: tooltip,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 250),
            style:
                (textStyle ?? Theme.of(context).textTheme.headline6!).copyWith(
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
