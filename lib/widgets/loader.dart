import 'dart:io';

import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final bool compact;

  const Loader({this.compact = false}) : super();

  Widget _buildAndroidCompact() {
    return Center(
      child: SizedBox(
        height: 20,
        width: 20,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(2),
            child: CircularProgressIndicator(
              color: Colors.grey,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAndroidNormalSized() {
    return CircularProgressIndicator(
      color: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? (compact ? _buildAndroidCompact() : _buildAndroidNormalSized())
        : SizedBox.fromSize(
            size: Size.square(24),
            child: CircularProgressIndicator.adaptive(),
          );
  }
}
