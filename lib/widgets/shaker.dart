import 'package:flutter/material.dart';
import 'dart:math';
import 'package:vector_math/vector_math_64.dart';

/// Shake the child widget via a [GlobalKey]
class Shaker extends StatefulWidget {
  final Widget child;

  const Shaker({Key? key, required this.child}) : super(key: key);

  @override
  ShakerState createState() => ShakerState();
}

/// Taken and modified from https://stackoverflow.com/a/66994041/15396325
class ShakerState extends State<Shaker> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500), // how long the shake happens
    )..addListener(() => setState(() {}));

    animation = Tween<double>(
      begin: 00,
      end: 200,
    ).animate(animationController);
  }

  Vector3 _shake() {
    double progress = animationController.value;
    double offset =
        sin(progress * pi * 6); // change 10 to make it vibrate faster
    return Vector3(offset * 17, 0, 0); // change 25 to make it vibrate wider
  }

  shake() {
    animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.translation(_shake()),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
