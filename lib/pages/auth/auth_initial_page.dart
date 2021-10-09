import 'package:flutter/material.dart';
import 'package:points/widgets/loader.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';

class AuthInitialPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NeumorphicScaffold(
      body: Center(
        child: Loader(),
      ),
    );
  }
}
