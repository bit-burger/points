import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PointsLogo extends StatelessWidget {
  final double? size;

  const PointsLogo({this.size});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "icons/logo.svg",
      height: size,
      width: size,
      color: Colors.black,
      semanticsLabel: "points",
    );
  }
}
