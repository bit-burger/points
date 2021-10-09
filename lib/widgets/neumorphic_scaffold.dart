import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class NeumorphicScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;

  const NeumorphicScaffold({
    required this.body,
    this.appBar,
  }) : super();

  @override
  Widget build(BuildContext context) {
    final theme = NeumorphicTheme.of(context)!.current!;
    return Scaffold(
      appBar: appBar,
      body: body,
      backgroundColor: theme.baseColor,
    );
  }
}
