import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:points/widgets/hider.dart';

class NeumorphicTextFormField extends FormField<String> {
  NeumorphicTextFormField({
    Key? key,
    String? hintText,
    String? errorText,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    AutovalidateMode? autovalidateMode,
    List<TextInputFormatter> inputFormatters = const [],
    TextInputAction? textInputAction,
    bool autofocus = false,
    TextInputType? keyboardType,
    FocusNode? focusNode,
    void Function(String)? onFieldSubmitted,
    void Function(String)? onChanged,
    bool obscureText = false,
  }) : super(
          key: key,
          onSaved: onSaved,
          autovalidateMode: autovalidateMode,
          validator: validator,
          builder: (FormFieldState<String> field) {
            final NeumorphicTextFormFieldState state =
                field as NeumorphicTextFormFieldState;
            late final String? finalErrorText;
            if (field.hasError) {
              finalErrorText = field.errorText;
            } else {
              finalErrorText = errorText;
            }
            return Builder(
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Neumorphic(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        selectionControls: _CustomColorSelectionHandle(
                          Theme.of(context)
                              .textSelectionTheme
                              .selectionHandleColor!,
                        ),
                        controller: state._effectiveController,
                        obscureText: obscureText,
                        keyboardType: keyboardType,
                        textInputAction: textInputAction,
                        autocorrect: false,
                        focusNode: focusNode,
                        autofocus: autofocus,
                        decoration: InputDecoration(
                          hintText: hintText,
                          border: InputBorder.none,
                        ),
                        onSubmitted: onFieldSubmitted,
                        onChanged: (s) {
                          if (onChanged != null) onChanged(s);
                          return state.didChange(s);
                        },
                        inputFormatters: inputFormatters,
                      ),
                      style: NeumorphicStyle(
                        depth: -NeumorphicTheme.depth(context)!,
                        boxShape: NeumorphicBoxShape.stadium(),
                      ),
                    ),
                    // SizeTransition(sizeFactor: sizeFactor),
                    Hider(
                      hide: finalErrorText == null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          finalErrorText ?? "",
                          style: Theme.of(context).textTheme.caption!.copyWith(
                                color: Theme.of(context).errorColor,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );

  @override
  NeumorphicTextFormFieldState createState() => NeumorphicTextFormFieldState();
}

/// Copied and modified from flutter/lib/src/material/text_form_field.dart (Flutter SDK)
class NeumorphicTextFormFieldState extends FormFieldState<String> {
  TextEditingController? _controller;

  TextEditingController? get _effectiveController => _controller;

  @override
  NeumorphicTextFormField get widget => super.widget as NeumorphicTextFormField;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didChange(String? value) {
    super.didChange(value);

    if (_effectiveController!.text != value)
      _effectiveController!.text = value ?? '';
  }

  @override
  void reset() {
    // setState will be called in the superclass, so even though state is being
    // manipulated, no setState call is needed here.
    _effectiveController!.text = widget.initialValue ?? '';
    super.reset();
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
