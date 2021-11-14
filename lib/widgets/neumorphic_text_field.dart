import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter/material.dart';

class NeumorphicTextField extends StatelessWidget {
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autocorrect;
  final bool autofocus;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final NeumorphicStyle? style;
  final InputDecoration? decoration;
  final Widget? trailing;

  NeumorphicTextField({
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.autocorrect = false,
    this.autofocus = false,
    this.hintText,
    this.inputFormatters,
    this.style,
    this.decoration,
    this.trailing,
  }) : super();

  @override
  Widget build(BuildContext context) {
    Widget content = SizedBox(
      height: 56,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextField(
          selectionControls: _CustomColorSelectionHandle(
            Theme.of(context).textSelectionTheme.selectionHandleColor!,
          ),
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autocorrect: autocorrect,
          focusNode: focusNode,
          autofocus: autofocus,
          decoration: (decoration ?? InputDecoration()).copyWith(
            hintText: hintText,
            border: InputBorder.none,
          ),
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
        ),
      ),
    );
    if (trailing != null) {
      content = Stack(
        children: [
          content,
          Align(alignment: Alignment.centerRight, child: trailing!),
        ],
      );
    }
    return Neumorphic(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: content,
      style: style ??
          NeumorphicStyle(
            depth: -NeumorphicTheme.depth(context)!,
            boxShape: NeumorphicBoxShape.stadium(),
          ),
    );
  }
}

/// Temporary fix as the selectionHandleColor does not work on iOS
/// Copied and modified from: https://github.com/flutter/flutter/issues/74890#issuecomment-901169865
class _CustomColorSelectionHandle extends TextSelectionControls {
  _CustomColorSelectionHandle(this.handleColor)
      : _controls = Platform.isIOS
            ? cupertinoTextSelectionControls
            : materialTextSelectionControls;

  final Color handleColor;
  final TextSelectionControls _controls;

  /// Wrap the given handle builder with the needed theme data for
  /// each platform to modify the color.
  Widget _wrapWithThemeData(Widget Function(BuildContext) builder) =>
      Platform.isIOS
          // ios handle uses the CupertinoTheme primary color, so override that.
          ? CupertinoTheme(
              data: CupertinoThemeData(primaryColor: handleColor),
              child: Builder(builder: builder))
          // material handle uses the selection handle color, so override that.
          : TextSelectionTheme(
              data: TextSelectionThemeData(selectionHandleColor: handleColor),
              child: Builder(builder: builder));

  @override
  Widget buildHandle(
      BuildContext context, TextSelectionHandleType type, double textLineHeight,
      [VoidCallback? onTap, double? startGlyphHeight, double? endGlyphHeight]) {
    return _wrapWithThemeData((BuildContext context) =>
        _controls.buildHandle(context, type, textLineHeight));
  }

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight,
      [double? startGlyphHeight, double? endGlyphHeight]) {
    return _controls.getHandleAnchor(type, textLineHeight);
  }

  @override
  Size getHandleSize(double textLineHeight) {
    return _controls.getHandleSize(textLineHeight);
  }

  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset position,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ClipboardStatusNotifier clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    return _controls.buildToolbar(
        context,
        globalEditableRegion,
        textLineHeight,
        position,
        endpoints,
        delegate,
        clipboardStatus,
        lastSecondaryTapDownPosition);
  }
}
