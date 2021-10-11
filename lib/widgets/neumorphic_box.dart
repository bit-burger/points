import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class NeumorphicBox extends StatelessWidget {
  final Widget child;

  const NeumorphicBox({required this.child}) : super();

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      child: child,
    );
  }
}
