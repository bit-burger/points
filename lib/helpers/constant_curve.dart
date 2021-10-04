import 'package:flutter/animation.dart';

class ConstantCurve extends Curve {
  final double constant;

  const ConstantCurve(this.constant);

  @override
  double transform(double t) {
    return constant;
  }
}
