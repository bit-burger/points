import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import 'neumorphic_action.dart';

/// Taken and modified from https://github.com/janoschp/simple_speed_dial

class SpeedDialChild {
  final Widget icon;
  final String label;
  final VoidCallback onPressed;

  SpeedDialChild({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
}

/// A
class NeumorphicSpeedDial extends StatefulWidget {
  const NeumorphicSpeedDial({
    required this.child,
    this.speedDialChildren,
    this.labelsStyle,
    this.controller,
    this.closedForegroundColor,
    this.openForegroundColor,
    this.closedBackgroundColor,
    this.openBackgroundColor,
  });

  final Widget child;

  final List<SpeedDialChild>? speedDialChildren;

  final TextStyle? labelsStyle;

  final AnimationController? controller;

  final Color? closedForegroundColor;

  final Color? openForegroundColor;

  final Color? closedBackgroundColor;

  final Color? openBackgroundColor;

  @override
  State<StatefulWidget> createState() {
    return _NeumorphicSpeedDialState();
  }
}

class _NeumorphicSpeedDialState extends State<NeumorphicSpeedDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<Animation<double>> _speedDialChildAnimations =
      <Animation<double>>[];

  @override
  void initState() {
    _animationController = widget.controller ??
        AnimationController(
            vsync: this, duration: const Duration(milliseconds: 450));
    _animationController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    final double fractionOfOneSpeedDialChild =
        1.0 / widget.speedDialChildren!.length;
    for (int speedDialChildIndex = 0;
        speedDialChildIndex < widget.speedDialChildren!.length;
        ++speedDialChildIndex) {
      final List<TweenSequenceItem<double>> tweenSequenceItems =
          <TweenSequenceItem<double>>[];

      final double firstWeight =
          fractionOfOneSpeedDialChild * speedDialChildIndex;
      if (firstWeight > 0.0) {
        tweenSequenceItems.add(TweenSequenceItem<double>(
          tween: ConstantTween<double>(0.0),
          weight: firstWeight,
        ));
      }

      tweenSequenceItems.add(TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: fractionOfOneSpeedDialChild,
      ));

      final double lastWeight = fractionOfOneSpeedDialChild *
          (widget.speedDialChildren!.length - 1 - speedDialChildIndex);
      if (lastWeight > 0.0) {
        tweenSequenceItems.add(TweenSequenceItem<double>(
            tween: ConstantTween<double>(1.0), weight: lastWeight));
      }

      _speedDialChildAnimations.insert(
          0,
          TweenSequence<double>(tweenSequenceItems)
              .animate(_animationController));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int speedDialChildAnimationIndex = 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (!_animationController.isDismissed)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.speedDialChildren
                      ?.map<Widget>((SpeedDialChild speedDialChild) {
                    final Widget speedDialChildWidget = Opacity(
                      opacity: _speedDialChildAnimations[
                              speedDialChildAnimationIndex]
                          .value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          ScaleTransition(
                            alignment: Alignment.bottomRight,
                            scale: _speedDialChildAnimations[
                                speedDialChildAnimationIndex],
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: NeumorphicButton(
                                child: SizedBox(
                                  width: 100,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        speedDialChild.label,
                                        style: widget.labelsStyle,
                                      ),
                                      SizedBox(width: 8),
                                      speedDialChild.icon,
                                    ],
                                  ),
                                ),
                                onPressed: () {
                                  _animationController.reverse();
                                  speedDialChild.onPressed.call();
                                },
                                minDistance: 3,
                                style: NeumorphicStyle(
                                  depth: 8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    speedDialChildAnimationIndex++;
                    return speedDialChildWidget;
                  }).toList() ??
                  <Widget>[],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: NeumorphicAction(
            child: widget.child,
            onPressed: () {
              if (_animationController.isDismissed) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            },
          ),
        )
      ],
    );
  }
}
