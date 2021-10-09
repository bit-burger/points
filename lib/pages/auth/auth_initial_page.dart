import 'package:flutter/material.dart';
import 'package:points/widgets/loader.dart';

class AuthInitialPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Loader(),
      ),
    );
  }
}
