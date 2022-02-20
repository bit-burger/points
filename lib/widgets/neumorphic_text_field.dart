import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

/// A [TextField] styled with a neumorphic design
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
