import 'package:flutter/material.dart';
import 'package:points/widgets/loader.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'auth_navigator.dart';

/// Shown by the [AuthNavigator], when it is waiting
/// for the auto log in to complete/fail
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
